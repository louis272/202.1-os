/// An abstract machine evaluating a concurrent program.
struct Interpreter {

  /// The status of an interpreter after performing a step of execution.
  enum Status {

    /// The program did not complete yet.
    case processing

    /// The program exited with the answer in the payload.
    case exited(Term)

  }

  /// The rest of a program after a particular point of execution.
  typealias Continuation = [(Term) -> Term]

  /// The memory shared by all processes.
  var memory: [Int]

  /// The processes in memory.
  var processes: [(control: Term, continuation: Continuation)]

  /// A map from a process to a bit specifying whether it is allocated.
  ///
  /// This property is used as a bitset. Each set bit indicates whether the corresponding position
  /// in `processes` denotes a process being currently allocated.
  var allocated: UInt64

  /// A map from a process to its children.
  var children: [UInt64]

  /// The identity of the process being executed.
  var executing: Int

  /// Creates an instance with the given program.
  init(_ entry: Term) {
    // Initialize the global memory.
    self.memory = Array(repeating: 0, count: 1024)

    // Allocate the process table.
    self.processes = Array(repeating: (.error, []), count: 64)
    self.children = Array(repeating: 0, count: 64)

    // Allocate the first process.
    self.processes[0] = (entry, [])
    self.allocated = 1
    self.executing = 0
  }

  /// Returns the processes that are still active but whose parents have terminated.
  func zombies() -> [Int] {
    // TODO
    var zombies: [Int] = []

    for i in 0..<64 {
      let isAllocated = ((allocated >> i) & 1) == 1

      if isAllocated {
        let process = processes[i]
        let parentTerminated: Bool

        parentTerminated = process.control.isValue && process.continuation.isEmpty

        // switch process.control {
        //   case .bool, .int, .variable:
        //     parentTerminated = process.continuation.isEmpty
        //   default:
        //     parentTerminated = false
        // }

        if parentTerminated {
          for j in 0..<64 {
            let isChild: Bool = ((children[i] >> j) & 1) == 1

            if isChild {
              let isChildAllocated = ((allocated >> j) & 1) == 1

              if isChildAllocated {
                let child = processes[j]
                let childTerminated: Bool

                childTerminated = child.control.isValue && child.continuation.isEmpty

                // switch child.control {
                //   case .bool, .int, .variable:
                //     childTerminated = child.continuation.isEmpty
                //   default:
                //     childTerminated = false
                // }

                if childTerminated {
                  zombies.append(j)
                }
              }
            }
          }
        }
      }
    }

    return zombies
  }

  /// Performs a single evaluation step and returns the status of the machine.
  mutating func step() -> Status {
    // Load and evaluate the next redex.
    let (control, continuation) = processes[executing]
    switch control {
    case .error:
      return fail()

    case .bool, .int, .variable, .abstraction:
      if let k = continuation.last {
        processes[executing] = (k(control), continuation.dropLast())
        return next()
      } else {
        return done()
      }

    case .application(.abstraction(let a), let b):
      processes[executing] = (b, continuation + [{ (r) in a[r, for: 0] }])
      return next()

    case .application(let a, let b):
      func k(_ r: Term) -> Term {
        if case .abstraction = r { .application(r, b) } else { .error }
      }
      processes[executing] = (a, continuation + [k])
      return next()

    case .conditional(let a, let b, let c):
      func k(_ r: Term) -> Term {
        if case .bool(let x) = r { x ? b : c } else { .error }
      }
      processes[executing] = (a, continuation + [k])
      return next()

    case .binary(let f, let a, let b) where !a.isValue:
      processes[executing] = (a, continuation + [{ (r) in .binary(f, r, b) }])
      return next()

    case .binary(let f, let a, let b) where !b.isValue:
      processes[executing] = (b, continuation + [{ (r) in .binary(f, a, r) }])
      return next()

    case .binary(.add, .int(let a), .int(let b)):
      processes[executing] = (.int(a + b), continuation)
      return next()

    case .binary(.sub, .int(let a), .int(let b)):
      processes[executing] = (.int(a - b), continuation)
      return next()

    case .binary(.eq, let a, let b):
      processes[executing] = (.bool(a == b), continuation)
      return next()

    case .binary(.ne, let a, let b):
      processes[executing] = (.bool(a != b), continuation)
      return next()

    case .binary(.lt, .int(let a), .int(let b)):
      processes[executing] = (.bool(a < b), continuation)
      return next()

    case .binary(.gt, .int(let a), .int(let b)):
      processes[executing] = (.bool(a > b), continuation)
      return next()

    case .read(let a) where !a.isValue:
      processes[executing] = (a, continuation + [{ (r) in .read(from: r) }])
      return next()

    case .read(.int(let a)):
      if UInt(bitPattern: a) < memory.count {
        processes[executing] = (.int(memory[a]), continuation)
        return next()
      } else {
        return fail()
      }

    case .write(let v, let a) where !v.isValue:
      processes[executing] = (v, continuation + [{ (r) in .write(r, to: a) }])
      return next()

    case .write(let v, let a) where !a.isValue:
      processes[executing] = (a, continuation + [{ (r) in .write(v, to: r) }])
      return next()

    case .write(.int(var v), .int(let a)):
      if UInt(bitPattern: a) < memory.count {
        swap(&v, &memory[a])
        processes[executing] = (.int(v), continuation)
        return next()
      } else {
        return fail()
      }

    case .fork:
      return fork(then: continuation)

    case .wait(.int(let n)):
      return wait(n, then: continuation)

    case .wait(let a):
      processes[executing] = (a, continuation + [{ (r) in .wait(r) }])
      return next()

    default:
      return fail()
    }
  }

  /// Prepares the machine for the next step and returns its status.
  private mutating func next() -> Status {
    let d = executing + 1
    let a = allocated >> d
    let n = a.trailingZeroBitCount
    executing = (n < 64) ? (n + d) : allocated.trailingZeroBitCount
    return .processing
  }

  /// Signals that the current process terminated with success, prepares the machine for the next
  /// step, and returns its status.
  private mutating func done() -> Status {
    if executing == 0 {
      return .exited(processes[executing].control)
    } else {
      return next()
    }
  }

  /// Signals that the current process failed, prepares the machine for the next step, and returns
  /// its status.
  ///
  /// This method is called when a process attempts to execute an illegal operation. The control
  /// term of the process is replaced by an error and its continuation is thrown away.
  private mutating func fail() -> Status {
    processes[executing] = (.error, [])
    allocated = allocated & ~(1 << executing)
    return done()
  }

  /// Executes the semantics of a redex forking the current process, prepares the machine for the
  /// next step, and returns its status.
  private mutating func fork(then k: Continuation) -> Status {
    // Look for a process slot.
    let child = (~allocated).trailingZeroBitCount

    // Is the process table full?
    if child >= 64 { return fail() }

    // Update the parent.
    processes[executing] = (.int(child), k)
    children[executing] |= (1 << child)

    // Allocate the child.
    processes[child] = (.int(0), k)
    allocated |= (1 << child)

    return next()
  }

  /// Executes the semantics of a redex waiting for `child` and resuming `k`, prepares the machine
  /// for the next step, and returns its status.
  private mutating func wait(_ child: Int, then k: Continuation) -> Status {
    // If child is 0, wait for any child
    if (child == 0) {
      var hasChild = false
      for i in 0..<64 {
        // If the child exists
        if ((children[executing] & (1 << i)) != 0) {
          // If this child is terminated, "wait" for it
          let child = processes[i]
          let childIsTerminated = child.control.isValue && child.continuation.isEmpty
          if childIsTerminated { return wait(i, then: k) }
          
          // If not terminated, go to the next one
          hasChild = true
        }
      }

      if !hasChild {
        return fail()
      }

      return next()

    } else {

      // Is the child identity valid?
      if ((children[executing] & (1 << child)) == 0) { return fail() }

      // Did the child terminate?
      switch processes[child] {
      case (.error, _):
        return fail()

      case (let r, let s) where r.isValue && s.isEmpty:
        processes[executing] = (r, k)
        children[executing] &= (1 << child)
        allocated &= ~(1 << child)
        return next()

      default:
        return next()
      }

    }
  }

}
