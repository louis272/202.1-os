/// A Petri net.
public struct PetriNet {

  /// The number of tokens consumed from and produced to a place by a transition.
  public struct Flow {

    /// The number of token produced, i.e., the number of preconditions.
    public var consumed: Int = 0

    /// The number of token produced, i.e., the number of postconditions.
    public var produced: Int = 0

    /// Creates an instance with the given properties.
    public init(consumed: Int, produced: Int) {
      self.consumed = consumed
      self.produced = produced
    }

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

  /// Returns the marking obtained after firing `s` form `m`.
  ///
  /// - Requires: `m` assigns each place in `self` and `t` is fireable from `m`.
  public func fire<S: Sequence<Int>>(_ s: S, from m: Marking) -> Marking {
    todo()
  }

  /// Returns a sequence of transitions fireable from `m` that leads to a marking satisfying `phi`
  /// if such marking exists; otherwise, returns `nil`.
  ///
  /// - Requires: `m` assigns each place in `self` and `t` is fireable from `m`.
  public func sequence(from m: Marking, toMarkingSatisfying phi: (Marking) -> Bool) -> [Int] {
    todo()
  }

}

/// A placeholder indicating that some code is not implemented yet.
fileprivate func todo() -> Never { fatalError("unimplemented") }
