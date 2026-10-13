/// Information about a page.
///
/// A page table entry (PTE) is a record describing how a page in the virtual memory space is
/// mapped to a frame in physical memory space.
///
/// A PTE is represented as a 16-bit integer, using the layout below:
///
///     ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
///     │ f │ e │ d │ c │ b │ a │ 9 │ 8 │ 7 │ 6 │ 5 │ 4 │ 3 │ 2 │ 1 │ 0 │
///     ╞═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╪═══╪═══╪═══╪═══╪═══╪═══╡
///     │ frame number                          │ - │ x │ w │ r │ p │ a │
///     └───────────────────────────────────────┴───┴───┴───┴───┴───┴───┘
///
/// The meaning of the flags stored in the least significant bits is as follows:
///
/// - `a` is set iff the page entry is defined.
/// - `p` is set iff the corresponding frame is present in main memory.
/// - `r` is set iff the page can be read.
/// - `w` is set iff the page can be written to.
/// - `x` is set iff the page can be executed.
///
/// Note that bit 5 is currently reserved.
///
/// If `a` is not set, the other bits must be set to 0 and the whole representation denotes the
/// absence of any value. This invariant can be used to represent an optional PTE without using
/// additional storage.
///
/// If `p` is set, the frame number identifies a frame in main memory. Otherwise, it identifies a
/// frame in secondary memory that should be swapped in before it can be accessed.
struct PageTableEntry {

  /// The raw representation of the entry.
  private(set) var rawValue: UInt16

  /// Creates an empty entry.
  init() {
    self.rawValue = 0
  }

  /// Creates an instance from its raw value.
  init(rawValue: UInt16) {
    self.rawValue = rawValue
  }

  /// Accesses the bit indicating whether the frame corresponding to this entry is present in main
  /// memory.
  var isPresent: Bool {
    get { (rawValue & 2) != 0 }
    set { rawValue = newValue ? (rawValue | 3) : (rawValue & ~2) }
  }

  /// Accesses the permissions of the page.
  var permissions: PagePermissions {
    get { PagePermissions(rawValue: UInt8((rawValue >> 2) & 3)) }
    set { rawValue = 1 | (rawValue & ~0x1c) | (UInt16(newValue.rawValue) << 2) }
  }

  /// Accesses the offset of the frame corresponding to the page described by this entry.
  var frame: UInt8 {
    get { UInt8(rawValue >> 6) }
    set { rawValue = 1 | (rawValue & 0x3f) | (UInt16(newValue) << 6) }
  }

}
