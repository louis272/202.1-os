/// A page protection flag.
public enum PagePermission: UInt8 {

  /// A bit indicating that a page can be read.
  case read = 1

  /// A bit indicating that a page can be modified.
  case write = 2

  /// A bit indicating that a page can be executed.
  case execute = 4

}

/// A set of page permission flags.
public struct PagePermissions {

  /// The raw representation of this set.
  public private(set) var rawValue: UInt8

  /// Creates an instance with its raw value.
  public init(rawValue: UInt8) {
    self.rawValue = rawValue
  }

  /// Creates an instance containing the given flags.
  public init(_ flags: [PagePermission]) {
    self.rawValue = flags.reduce(0, { (r, f) in r | f.rawValue })
  }

  /// Returns `true` iff `self` contains all the flags in `other`.
  public func isSuperset(of other: PagePermissions) -> Bool {
    (other.rawValue & self.rawValue) == other.rawValue
  }

}

extension PagePermissions: ExpressibleByArrayLiteral {

  public init(arrayLiteral flags: PagePermission...) {
    self.init(flags)
  }

}
