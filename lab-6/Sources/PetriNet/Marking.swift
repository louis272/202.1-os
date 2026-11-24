/// A mapping from a place to the number of tokens that it contains.
public struct Marking: Hashable, Sendable {

  /// A table from a place to its number of tokens.
  private var assignments: [Int]

  /// Accesses the number of tokens in `p`.
  public subscript(p: Int) -> Int {
    get { assignments[p] }
    set { assignments[p] = newValue }
  }

  /// Creates an instance with the given assignments.
  ///
  /// - Requires: each assignment is nonnegative.
  public init(_ assignments: [Int]) {
    precondition(assignments.allSatisfy({ (n) in n >= 0 }), "invalid assignment")
    self.assignments = assignments
  }

  /// Returns a marking obtained by applying `transform` to each assignment in `self`.
  public func map(_ transform: (Int, Int) -> Int) -> Marking {
    .init(assignments.enumerated().map({ (p, n) in transform(p, n) }))
  }

}

extension Marking: ExpressibleByArrayLiteral {

  public typealias ArrayLiteralElement = Int

  public init(arrayLiteral elements: Int...) {
    self.init(elements)
  }

}
