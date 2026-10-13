/// Information about a frame, i.e., the storage of a page in physical memory.
///
/// A frame descriptor is a record describing a region of physical memory that forms a frame (i.e.,
/// the storage of a virtual page). The descriptor of a frame `f` is logically described as a
/// 4-tuple `(r, p, br, pp)` where:
///
/// - `r` is a flag set iff `f` has been referenced since the last stealing pass (see below),
/// - `p` is a flag set iff `f` cannot be evicted (see below),
/// - `br` is a sequence of "back" references to PTEs referring to `f`, and
/// - `pp` optionally identifies the permanent position of `f` in secondary memory.
///
/// These components are represented as an array of four 8-bit unsigned integers:
///
///     ┌────────╥───┬───┬───┬───┬───┬───┬───┬───┐
///     │        ║ 7 │ 6 │ 5 │ 4 │ 3 │ 2 │ 1 │ 0 │
///     ╞════════╬═══╧═══╪═══╪═══╪═══╧═══╪═══╪═══╡
///     │ raw[0] ║ pp hi │ - │ - │ brcnt │ p │ r │
///     ├────────╫───────┴───┴───┴───────┴───┴───┤
///     │ raw[1] ║ pp lo                         │
///     ├────────╫───────────────────────────────┤
///     │ raw[2] ║ backref 0                     │
///     ├────────╫───────────────────────────────┤
///     │ raw[3] ║ backref 1                     │
///     └────────╨───────────────────────────────┘
///
/// Note that bits 4 and 5 are currently reserved.
///
/// The permenent position identifier (`pp`) is represented as a 10-bit unsigned integer. Its two
/// highest bits are stored in `raw[0]` whereas the other bits are stored in `raw[1]`.
///
/// The sequence of back references `br` is used to update the page translation table when a frame
/// is swapped out. This feature is only partially implemented. Currently, if there are less than
/// three references, then `brcnt` contains the length of the sequence, which is stored in `raw[2]`
/// and `raw[3]` as an array of offsets in physical memory. Otherwise, `brcnt` is equal to 3 and
/// the contents of `raw[2]` and `raw[3]` is unspecified.
///
/// When a page not currently in main memory is accessed (or allocated), the system must first map
/// that page to some frame. If all frames are occupied, the system will try to "steal" the frame
/// from one of the current pages. The victim is selected by looking at the `r` flag of each frame.
/// If it is unset (and the frame is not pinned), then the corresponding page will be evicted.
/// Otherwise, `r` is reset and the system will look for a better candidate. The `r` flag of the
/// frame will be set again after the next access to the corresponding page. This strategy favors
/// the eviction of pages that are not under heavy use.
struct FrameDescriptor {

  /// The raw representation of this frame descriptor.
  private var raw: InlineArray<4, UInt8>

  /// Creates a new instance.
  init() {
    raw = .init(repeating: 0)
  }

  /// Resets the value of this descriptor.
  mutating func reset() {
    raw = .init(repeating: 0)
  }

  /// Accesses the bit indicating whether the frame has been referenced since the last page
  /// stealing pass.
  var isReferenced: Bool {
    get { (raw[0] & 1) != 0 }
    set { raw[0] = newValue ? (raw[0] | 1) : (raw[0] & ~1) }
  }

  /// Accesses the bit indicating whether the frame can never be evicted.
  var isPinned: Bool {
    get { (raw[0] & 2) != 0 }
    set { raw[0] = newValue ? (raw[0] | 2) : (raw[0] & ~2) }
  }

  /// Accesses the position of the frame in secondary memory.
  var permanentPosition: UInt16 {
    get { UInt16(raw[1]) | UInt16((raw[0] & 0xc0) << 8) }
    set {
      raw[1] = UInt8(newValue & 0xff)
      raw[0] = (raw[0] & 0x3f) | UInt8(newValue >> 8)
    }
  }

  /// `true` iff the frame is not piined and has not been referenced.
  var isReadyForEviction: Bool {
    ((raw[0] & 3) ^ 1) == 1
  }

  /// The number of entries in the back reference list of this frame.
  var backReferenceCount: Int {
    Int(raw[0] >> 2)
  }

  /// Returns the result `action` called with the page table entries mapped to this frame.
  func withBackReferences<T>(_ action: (Span<UInt8>) -> T) -> T {
    let e = 2 + min(backReferenceCount, 2)
    return action(raw.span.extracting(2 ..< e))
  }

  /// Appends the page entry with the offset `entryOffset` to the back reference list.
  mutating func appendBackReference(_ entryOffset: UInt8) {
    let c = backReferenceCount
    if (c < 2) {
      raw[c + 2] = entryOffset
    }
    if (c < 3) {
      raw[0] = (raw[0] & 0xc3) | UInt8((c + 1) << 2)
    }
  }

  /// Removes all back references from this frame.
  mutating func removeAllBackReferences() {
    raw[0] = raw[0] & 0xc3
  }

}
