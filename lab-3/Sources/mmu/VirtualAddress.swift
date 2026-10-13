/// An index in a page translation table together with an offset in a physical frame.
///
/// A virtual address is represented as a 16-bit unsigned integer that encodes an index in page
/// translation table, which identifies a page, and an offset in the phyiscal frame corresponding
/// that corresponds to that frame.
///
/// The index is expressed as a triple of directory indices (see `Machine::translate`), encoded in
/// the 8 highest bit of the address as follows:
///
///     ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
///     │ f │ e │ d │ c │ b │ a │ 9 │ 8 │ 7 │ 6 │ 5 │ 4 │ 3 │ 2 │ 1 │ 0 │
///     ╞═══╧═══╪═══╧═══╧═══╪═══╧═══╧═══╪═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╡
///     │ L0    │ L1        │ L2        │ offset in frame               │
///     └───────┴───────────┴───────────┴───────────────────────────────┘
///
/// An address whose representation is equal to zero is called a *null address*.
public struct VirtualAddress {

  /// The raw value of this address.
  public let rawValue: UInt16

  /// `true` iff `self` is the null address.
  public var isNull: Bool {
    rawValue == 0
  }

  /// Returns the address of the page containing this address.
  public func page() -> VirtualAddress {
    VirtualAddress(rawValue: rawValue & ~0xff)
  }

  /// Returns this address advanced by the given offset.
  public func advanced(by offset: UInt16) -> VirtualAddress {
    VirtualAddress(rawValue: rawValue + offset)
  }

}

extension VirtualAddress: ExpressibleByIntegerLiteral {

  public init(integerLiteral value: Int) {
    self.init(rawValue: UInt16(value))
  }

}

extension VirtualAddress: CustomStringConvertible {

  public var description: String {
    let a = String(rawValue, radix: 16)
    let z = String(repeating: "0", count: 4 - a.count)
    return "0x\(z)\(a)"
  }

}
