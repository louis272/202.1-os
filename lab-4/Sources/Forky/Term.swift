/// A program.
indirect enum Term: Equatable {

  /// An error.
  case error

  /// A Boolean constant.
  case bool(Bool)

  /// An integer constant.
  case int(Int)

  /// A variable.
  case variable(Int)

  /// An abstraction.
  case abstraction(Term)

  /// The application of an abstraction.
  case application(Term, Term)

  /// A conditional term.
  ///
  /// This term evaluates to the `then` branch iff the condition evaluates to `true`; otherwise, it
  /// evaluates to the `else` branch.
  case conditional(if: Term, then: Term, else: Term)

  /// The application of a built-in binary operator.
  case binary(BinaryOperator, Term, Term)

  /// A global read.
  ///
  /// This term evaluates to the contents of the cell at the address specified in the payload. The
  /// result is an integer or an error if the address is invalid.
  case read(from: Term)

  /// A global write.
  ///
  /// This term writes `value`, which denotes an integer, to the cell at the address specified in
  /// the payload and returns the value that was stored before the update.
  case write(Term, to: Term)

  /// The forking of a process.
  ///
  /// This term evaluates to `0` for the child and to the identity of the child for the parent,
  /// which expressed as an integer value.
  case fork

  /// The waiting of a child process.
  ///
  /// This term evaluates to the identity of the process that has been waited.
  case wait(Term)

}

extension Term {

  /// `true` iff `self` is a value.
  var isValue: Bool {
    switch self {
    case .int, .bool, .abstraction:
      return true
    default:
      return false
    }
  }

  /// Returns `self` in which occurrences of the variable `n` have been replaced with `v`.
  subscript(_ v: Term, for n: Int) -> Term {
    switch self {
    case .error, .int, .bool:
      return self
    case .variable(let x):
      return (x == n) ? v : self
    case .abstraction(let e):
      return .abstraction(e[v, for: n + 1])
    case .application(let f, let a):
      return .application(f[v, for: n], a[v, for: n])
    case .conditional(let a, let b, let c):
      return .conditional(if: a[v, for: n], then: b[v, for: n], else: c[v, for: n])
    case .binary(let f, let a, let b):
      return .binary(f, a[v, for: n], b[v, for: n])
    case .read(let a):
      return .read(from: a[v, for: n])
    case .write(let a, let b):
      return .write(a[v, for: n], to: b[v, for: n])
    case .fork:
      return self
    case .wait(let e):
      return .wait(e[v, for: n])
    }
  }

}
