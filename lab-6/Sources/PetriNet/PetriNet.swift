/// A Petri net.
public struct PetriNet: Sendable {

  /// The number of tokens consumed from and produced to a place by a transition.
  public struct Flow: Sendable {

    /// The number of token produced, i.e., the number of preconditions.
    public var consumed: Int = 0

    /// The number of token produced, i.e., the number of postconditions.
    public var produced: Int = 0

  }

  /// The number of places in the net.
  public let placeCount: Int

  /// The number of transitions in the net.
  public let transitionCount: Int

  /// A table mapping a transition to its pre/postconditions.
  ///
  /// This property is a `P * T` matrix where `P` and `T` are the numbers of places and transitions
  /// in the net, respectively. Let `p` be a place and `t` a transition, the element at position
  /// `p * T + t` is a pair `(a, b)` where `a` is the number of tokens `t` consumes from `p` and
  /// `b` is the number of tokens `t` produces in `p`.
  private var flow: [Flow]

  /// Creates a new instance with the given number of places and transitions.
  public init(placeCount: Int, transitionCount: Int) {
    self.placeCount = placeCount
    self.transitionCount = transitionCount
    self.flow = .init(repeating: .init(), count: placeCount * transitionCount)
  }

  /// Accesses the number of tokens `t` consumes from `p`.
  public subscript(transition t: Int, place p: Int) -> Flow {
    get {
      precondition(UInt(bitPattern: p) < placeCount, "invalid place")
      precondition(UInt(bitPattern: t) < transitionCount, "invalid transition")
      return flow[p * transitionCount + t]
    }
    _modify {
      precondition(UInt(bitPattern: p) < placeCount, "invalid place")
      precondition(UInt(bitPattern: t) < transitionCount, "invalid transition")
      yield &flow[p * transitionCount + t]
    }
  }

  /// Returns `true` iff `t` is fireable from `m`.
  ///
  /// - Requires: `m` assigns each place in `self`.
  public func fireable(_ t: Int, from m: Marking) -> Bool {
    (0 ..< placeCount).allSatisfy({ (p) in self[transition: t, place: p].consumed <= m[p] })
  }

  /// Returns `true` iff `s` is fireable from `m`.
  ///
  /// - Requires: `m` assigns each place in `self`.
  public func fireable<S: Sequence<Int>>(_ s: S, from m: Marking) -> Bool {
    todo()
  }

  /// Returns the marking obtained after firing `t` from `m`.
  ///
  /// - Requires: `m` assigns each place in `self` and `t` is fireable from `m`.
  public func fire(_ t: Int, from m: Marking) -> Marking {
    m.map({ (p, n) in
      let x = self[transition: t, place: p]
      return n - x.consumed + x.produced
    })
  }

  /// Returns all possible successors of `m`.
  ///
  /// - Requires: `m` assigns each place in `self`.
  public func successors(_ m: Marking) async -> [ReachabilityGraph.Successor] {
    typealias S = ReachabilityGraph.Successor

    return await withTaskGroup(of: S?.self, returning: [S].self) { (g) in
      for t in 0 ..< transitionCount {
        g.addTask {
          if fireable(t, from: m) {
            return .some((t, fire(t, from: m)))
          } else {
            return nil
          }
        }
      }

      var r: [S] = []
      while let item = await g.next() {
        if case .some(let s) = item { r.append(s) }
      }
      return r
    }
  }

  /// Returns the set of markings reachable from `m`.
  ///
  /// - Requires: `self` is bounded.
  public func states() async -> ReachabilityGraph {
    todo()
  }

  /// Returns the liveness of `t` for `m`.
  ///
  /// - Requires: `m` assigns each place in `self` and `self` is bounded.
  public func liveness(_ t: Int, from m: Marking) -> TransitionLiveness {
    todo()
  }

}

/// A placeholder indicating that some code is not implemented yet.
fileprivate func todo() -> Never { fatalError("unimplemented") }
