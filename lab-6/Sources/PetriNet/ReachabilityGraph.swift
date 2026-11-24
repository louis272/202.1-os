/// A graph containing representing the state space of a Petri net.
public struct ReachabilityGraph: Sendable {

  /// An outgoing edge in a rachability graph.
  public typealias Successor = (transition: Int, marking: Marking)

  /// The markings in the graph and their successors.
  public private(set) var successors: [Marking: [Successor]]

  /// Creates an empty instance.
  public init() {
    self.successors = [:]
  }

  /// The markings in the graphl.
  public var markings: Dictionary<Marking, [Successor]>.Keys {
    successors.keys
  }

  /// Returns `true` iff `m` is in the graph.
  public func contains(_ m: Marking) -> Bool {
    successors[m] != nil
  }

  /// Inserts the given marking to the graph, returning `true` iff it was not already present.
  @discardableResult
  public mutating func insertMarking(_ m: Marking) -> Bool {
    modify(&successors[m]) { (s) in
      if s != nil {
        return false
      } else {
        s = []
        return true
      }
    }
  }

  /// Inserts an edge labeled by `t` between `m0` and and `m1`, returning `true` iff it was not
  /// already present.
  ///
  /// `m1` is added to the graph if it was not present already.
  @discardableResult
  public mutating func insertEdge(from m0: Marking, to m1: Marking, labeledBy t: Int) -> Bool {
    insertMarking(m1)
    return modify(&successors[m0, default: []]) { (s) in
      let i = s.partitioningIndex(by: { (a) in a.transition > t })
      if (i < s.count) && (s[i].transition == t) {
        return false
      } else {
        s.insert((t, m1), at: i)
        return true
      }
    }
  }

  /// Returns the result of `action` applied to the current successors of `m`, if any.
  private mutating func withSuccessors<R>(_ m: Marking, action: (inout [Successor]?) -> R) -> R {
    action(&successors[m])
  }

}

/// Returns the result of applying `action` to `value`.
private func modify<T, R>(_ value: inout T, _ action: (inout T) -> R) -> R {
  action(&value)
}
