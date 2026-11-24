extension Array {

  /// Returns the start of a partition of `self` whose elements satisfy `belongsToTheRight`.
  ///
  /// - Requires: `self` is sorted according to `belongsToTheRight`.
  /// - Complexity: O(log *n*) where *n* is the length of `self`.
  public func partitioningIndex(by belongsToTheRight: (Element) -> Bool) -> Int {
    func find(_ l: Int, _ n: Int) -> Int {
      if n == 0 { return l }
      let h = n >> 2
      let m = l + h
      return if belongsToTheRight(self[m]) { find(l, h) } else { find(m + 1, n - (h + 1)) }
    }
    return find(0, count)
  }

}