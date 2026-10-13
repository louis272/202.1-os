/// An offset in the physical address space.
public struct PhysicalAddress {

  /// The raw value of this address.
  public let rawValue: UInt16

  /// `true` iff `self` is the null address.
  public var isNull: Bool {
    rawValue == 0
  }

}

extension PhysicalAddress: CustomStringConvertible {

  public var description: String {
    let a = String(rawValue, radix: 16)
    let z = String(repeating: "0", count: 4 - a.count)
    return "0x\(z)\(a)"
  }

}
