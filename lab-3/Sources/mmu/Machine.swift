/// A virtual machine and its operating system.
///
/// Instances of this type model a virtual machine equipped with a single-core CPU, 4KB of main
/// memory, and 256KB of secondary memory.
///
/// The system implements demand paging. The virtual address space is represented using the full
/// range of a 16-bit unsigned integer, mapping onto 12-bit physical address space, segmenting
/// memory into 256-byte pages. Address mappings are encoded by a multi-level page translation
/// table indexed by the 8 most significant bits of a virtual address.
///
/// The page translation table has three levels, denoted by *L0*, *L1*, and *L2*, respectively.
/// Each level is composed of directories that represent nodes or leaves in a tree. Specifically,
/// *L0* encodes the root node and consists of only one directory with 4 entries, *L1* can contain
/// up to 4 directories (one per child of the root) of 8 entries, and *L2* can contain up to 32
/// directories (one per child at *L1*) of 8 entries.
///
/// Each directory entry is represented as a 16-bit unsigned integer, which encode a union of three
/// different type of values:
///
/// - If the entry is equal to zero, then any translation going through the corresponding node
///   should fail.
/// - If the least significant bit of the entry is set, then the entry stores a page table entry
//    and the page walk can end, even at level *L0* or *L1*.
/// - Otherwise, the entry encodes the address of a directory in the next level as an offset in
///   physical memory.
///
/// Note that the directory entries at *L2* can only be equal to zero or encode a PTE since the
/// translation table has only three levels.
///
/// Virtual addresses from 0xf800 to 0xf8ff are reserved for the kernel and mapped to the first
/// frame of the system's main memory, which is pinned. The layout of the frame is as follows:
///
///     ┌─────────────╥─────────────────────┐
///     │ 0x00 - 0x40 ║ frame table         │
///     ├─────────────╫─────────────────────┤
///     │ 0x40 - 0x42 ║ free map            │
///     ├─────────────╫─────────────────────┤
///     │ 0x42 - 0x44 ║ kernel break (kbrk) │
///     ├─────────────╫─────────────────────┤
///     │ 0x44 - 0x4c ║ page map root (L0)  │
///     ├─────────────╫─────────────────────┤
///     │ 0x4c - 0xff ║ unallocated pool    │
///     └─────────────╨─────────────────────┘
///
/// Kernel memory can be allocated with `kalloc`, which reserves space from the unallocated
/// pool by moving the kernel break. There is currently no way to deallocate kernel memory.
public struct Machine: ~Copyable {

  /// The size of secondary memory, in number of slots.
  private static let secondaryMemorySlotCount = 1024

  /// The offset of the free map in main memory.
  private static let freeMapOffset = 64

  /// The offset of the kernel break in main memory.
  private static let kernelBreakOffset = 66

  /// The offset of the page map in main memory.
  private static let pageMapOffset = 68

  /// The number of bits by which an address should be shifted to the right to read the index of
  /// `(i + 1)`-th translation directory level.
  private static let shifts: [UInt16] = [11, 8]

  /// The mask to apply to read the index of the `(i + 1)`-th translation directory level.
  private static let masks: [UInt16] = [0xc0ff, 0xf8ff, 0xffff]

  /// The main memory of the machine.
  ///
  /// The system has 4KB of memory, divided in 16 pages of 256 bytes.
  private var mainMemory: InlineArray<512, UInt64>

  /// The secondary memory of the machine.
  ///
  /// Secondary memory is also divided in frame slots of 256 bytes. The first slot is reserved to
  /// store a pointer to the next available region. A region `r` is denoted by a pair `(o, l)`
  /// where `o` is the offset to the start of the region and `l` is its length.
  private var secondaryMemory: UnsafeMutableRawPointer

  /// Creates a new instance.
  public init() {
    // Zero-initialize main memory.
    self.mainMemory = .init(repeating: 0)

    // Allocate 1024 slots of secondary memory and initialize a bitmap indicating which slots are
    // free. The map itself occupies the first slot, using a bit for each slot (i.e., 128 bytes).
    self.secondaryMemory = .allocate(
      byteCount: Machine.secondaryMemorySlotCount * 256,
      alignment: MemoryLayout<UInt64>.alignment)
    self.secondaryMemory.initializeMemory(as: UInt8.self, repeating: 0xff, count: 128)
    self.secondaryMemory.initializeMemory(as: UInt8.self, to: 0xfe)

    // Initialize the free map.
    self.freeMap = 0xffff

    // Initialize the kernel break as the first 8-aligned offset after the page map.
    let brk = Machine.pageMapOffset + 4
    self.kbrk = PhysicalAddress(rawValue: UInt16(brk + (-(brk & 7) & 7)))

    // Initialize the page translation table.
    self.initializePageTranslationTable()
  }

  deinit {
    // Deallocate secondary memory.
    self.secondaryMemory.deallocate()
  }

  /// The size of the main memory, in bytes.
  public var mainMemorySize: Int {
    mainMemory.count << 3
  }

  /// A bitmap describing which frames of the main memory are free.
  private var freeMap: UInt16 {
    get { withUnsafeMainMemory(from: Machine.freeMapOffset, read(UInt16.self)) }
    set { withUnsafeMutableMainMemory(from: Machine.freeMapOffset, write(newValue)) }
  }

  /// The position of the "kernel break".
  ///
  /// The kernel break is the first 8-byte aligned physical address that the kernel may use to
  /// allocate heap memory.
  private var kbrk: PhysicalAddress {
    get { withUnsafeMainMemory(from: Machine.kernelBreakOffset, read(PhysicalAddress.self)) }
    set { withUnsafeMutableMainMemory(from: Machine.kernelBreakOffset, write(newValue)) }
  }

  /// Allocates `count` bytes of memory from in the kernel heap and returns the address of the
  /// newly allocated memory.
  ///
  /// The returned address is aligned at 8.
  private mutating func kalloc(count: Int) -> PhysicalAddress {
    let k = self.kbrk
    let a = Int(k.rawValue) + count
    let b = a + (-(a & 7) & 7)

    // Did we run out of memory (kernel occupies the first frame)?
    precondition(b < 0x0100, "machine is out of kernel memory")
    self.kbrk = PhysicalAddress(rawValue: UInt16(b))
    return k
  }

  /// Returns the result `action` called with a pointer to an instance of `T` referring to the main
  /// memory's base address advanced by `offset`.
  ///
  /// - Requires: `offset` is in the range `0 ..< self.mainMemorySize`.
  private func withUnsafeMainMemory<T, R>(
    from offset: Int, as: T.Type = T.self, _ action: (UnsafePointer<T>) -> R
  ) -> R {
    precondition(UInt(bitPattern: offset) < mainMemorySize, "offset is out of bounds")
    precondition((offset & (MemoryLayout<T>.alignment - 1)) == 0, "offset is misaligned")
    return withUnsafeBytes(of: mainMemory) { (m) in
      action(m.baseAddress!.advanced(by: offset).assumingMemoryBound(to: T.self))
    }
  }

  /// Returns the result `action` called with a pointer to an instance of `T` referring to the main
  /// memory at `address`.
  ///
  /// - Requires: `address` is a valid address in main memory.
  private func withUnsafeMainMemory<T, R>(
    at address: PhysicalAddress, as: T.Type = T.self, _ action: (UnsafePointer<T>) -> R
  ) -> R {
    withUnsafeMainMemory(from: Int(address.rawValue), as: T.self, action)
  }

  /// Returns the result `action` called with a pointer to an instance of `T` referring to the main
  /// memory's base address advanced by `offset`.
  ///
  /// - Requires: `offset` is in the range `0 ..< self.mainMemorySize`.
  private mutating func withUnsafeMutableMainMemory<T, R>(
    from offset: Int, as: T.Type = T.self, _ action: (UnsafeMutablePointer<T>) -> R
  ) -> R {
    precondition(UInt(bitPattern: offset) < mainMemorySize, "offset is out of bounds")
    precondition((offset & (MemoryLayout<T>.alignment - 1)) == 0, "offset is misaligned")
    return withUnsafeMutableBytes(of: &mainMemory) { (m) in
      action(m.baseAddress!.advanced(by: offset).assumingMemoryBound(to: T.self))
    }
  }

  /// Returns the result `action` called with a pointer to an instance of `T` referring to the main
  /// memory at `address`.
  ///
  /// - Requires: `address` is a valid address in main memory.
  private mutating func withUnsafeMutableMainMemory<T, R>(
    at address: PhysicalAddress, as: T.Type = T.self, _ action: (UnsafeMutablePointer<T>) -> R
  ) -> R {
    withUnsafeMutableMainMemory(from: Int(address.rawValue), as: T.self, action)
  }

  /// Returns the result `action` called with a pointer to the table describing how each frame of
  /// the main memory is occupied.
  private mutating func withUnsafeMutableFrameTable<R>(
    _ action: (UnsafeMutablePointer<FrameDescriptor>) -> R
  ) -> R {
    withUnsafeMutableMainMemory(from: 0, as: FrameDescriptor.self, action)
  }

  /// Returns the result `action` called with a pointer to the root of the page translation table.
  private mutating func withUnsafeMutablePageMap<R>(
    _ action: (UnsafeMutablePointer<UInt16>) -> R
  ) -> R {
    withUnsafeMutableMainMemory(from: Machine.pageMapOffset, as: UInt16.self, action)
  }

  /// Initializes the page translation table of this machine.
  ///
  /// The page translation is initialized so that addresses from 0xf800 to 0xf8ff map to the first
  /// frame of the main memory, which is pinned. This frame is used to store the kernel's main data
  /// structures, such as the page map and the frame table.
  private mutating func initializePageTranslationTable() {
    // Allocate space for the first page directory and assign its address to `page_map[3]`.
    let d = kalloc(count: 16)
    withUnsafeMutablePageMap { (m) in m[3] = d.rawValue }

    // Write a single page table entry at `d[7]`.
    var e = PageTableEntry()
    e.isPresent = true
    e.permissions = [.read, .write]
    e.frame = 0
    withUnsafeMutableMainMemory(at: d, as: PageTableEntry.self) { (m) in m[7] = e }

    // Update the frame table.
    withUnsafeMutableFrameTable { (m) in
      m[0].isPinned = true
      m[0].appendBackReference(UInt8(d.rawValue))
    }

    // Update the free map.
    freeMap = 0xfffe
  }

  /// Reads and returns the byte stored at `va`.
  ///
  /// - Requires: `va` is mapped and has read permissions.
  public mutating func load(from va: VirtualAddress) -> UInt8 {
    guard let pa = translate(va, for: [.read]) else { fatalError("segfault") }
    return withUnsafeMainMemory(at: pa, read(UInt8.self))
  }

  /// Writes `byte` to `va`.
  ///
  /// - Requires: `va` is mapped and has write permissions.
  public mutating func store(_ byte: UInt8, to va: VirtualAddress) {
    guard let pa = translate(va, for: [.write]) else { fatalError("segfault") }
    withUnsafeMutableMainMemory(at: pa, write(byte))
  }

  /// Creates a new mapping in the virtual address space with a capacity of at least `byteCount`
  /// bytes and `permissions`.
  ///
  /// If `hint` is null, then the kernel chooses the (page-aligned) address at which to create the
  /// mapping. If `hint` is not null, then the kernel picks a nearby page boundary ans attempts to
  /// create the mapping there. If another mapping already exists there, the kernel picks a new
  /// address that may or may not depend on the hint.
  ///
  /// The result is the address of the new mapping if the allocation succeeded or `nil` otheriwse.
  public mutating func mmap(
    byteCount: Int, nearby hint: VirtualAddress, for ps: PagePermissions
  ) -> VirtualAddress? {
    // TODO
    nil
  }

  /// Information about an entry in a page directory.
  public struct PageDirectoryEntry {

    /// The address of the entry in main memory.
    let address: PhysicalAddress

    /// The level of the directory containing the entry.
    let level: UInt8

  }

  /// A page fault handler.
  public typealias FaultHandler = (inout Self, PageDirectoryEntry) -> PhysicalAddress?

  /// Returns the physical address corresponding to `va` iff `va` is mapped and accessible with
  /// `ps`; otherwise, returns `nil`.
  ///
  /// The method calls `handleFault(&self, pd)` if `va` is a non-null address that is not currently
  /// mapped, where `pd` is the page directory at which the fault occurred. The handler is expected
  /// to return the physical address that would have been found if the page was mapped (possibly
  /// after allocating a new page) if `va` cannot be mapped.
  public mutating func translate(
    _ va: VirtualAddress, for ps: PagePermissions,
    handlingFaultWith handleFault: FaultHandler = { (_, _) in nil }
  ) -> PhysicalAddress? {
    // The null address has no translation.
    if va.isNull { return nil }

    // Get the address of the first entry, which is equal to the base address of the page map
    // offset by `va`'s two most signigicant bits'.
    var pd = PhysicalAddress(
      rawValue: UInt16(Machine.pageMapOffset).advanced(
        by: Int(va.rawValue >> 14),
        stridesOf: UInt16.self))

    // Walk the page table.
    for i in 0 ... 2 {
      // Read the entry.
      let entry = withUnsafeMainMemory(at: pd, read(UInt16.self))

      // The null address has no translation.
      if entry == 0 {
        return handleFault(&self, PageDirectoryEntry(address: pd, level: UInt8(i)))
      }

      // If we reached L2 or if the least significant bit of `entry` is set, then `entry` is the
      // raw value of a page table entry rather than a physical address.
      if (i == 2) || ((entry & 1) != 0) {
        // Make sure the remaining directory bits are zeroed-out.
        if (va.rawValue & ~Machine.masks[i]) != 0 { return nil }
        // Decode the page entry.
        return translate(va, for: ps, withPageTableEntryAt: pd)
      }

      // If `entry` is less than 4096, then it encodes the physical address of the next directory.
      else if entry < 4096 {
        pd = PhysicalAddress(
          rawValue: entry.advanced(
            by: Int(va.rawValue >> Machine.shifts[i]) & 0x7,
            stridesOf: UInt16.self))
      }

      // Otherwise, we're out of luck.
      else { break }
    }

    fatalError("corrupted page translation table")
  }

  /// Returns the physical address corresponding to `va` iff `va` is mapped and accessible with
  /// `ps`, knowing that `va` resides in the page described by the page table entry at `pa`.
  ///
  /// This method is called internally after the page entry corresponding to `va` has been found,
  /// as a result of a page walk.
  ///
  /// If the frame storing the page is not in main memory, its contents is retrived from secondary
  /// memory and the page table entry at `pa` is updated to refer to physical location (in main
  /// memory) of the frame where the page's contents has been written.
  private mutating func translate(
    _ va: VirtualAddress, for ps: PagePermissions, withPageTableEntryAt pa: PhysicalAddress
  ) -> PhysicalAddress? {
    var pte = withUnsafeMainMemory(at: pa, read(PageTableEntry.self))

    // Does the page have the right protection?
    if !pte.permissions.isSuperset(of: ps) { return nil }

    var frame: UInt8 = 0xff

    // Is the page in main memory?
    if pte.isPresent {
      frame = pte.frame
    }

    // Otherwise, the frame number contains the location where the page has been swapped out.
    else {
      frame = UInt8(swapVictim(with: UInt16(pte.frame)))
      pte.frame = frame
      pte.isPresent = true
      withUnsafeMutableMainMemory(at: pa, write(pte))

      // Update the frame so that it points back to the page table entry that has been modified.
      // We can assume `pte` refers directly to some location in the page translation table since
      // the referred frame would have been present in memory otherwise.
      withUnsafeMutableFrameTable { (m) in
        m[Int(frame)].appendBackReference(UInt8(pa.rawValue))
      }
    }

    withUnsafeMutableFrameTable { (m) in m[Int(frame)].isReferenced = true }
    return PhysicalAddress(rawValue: (UInt16(frame) << 8) | (va.rawValue & 0xff))
  }

  /// If `va` is mapped, returns the result of `translate(va, for: ps)`; otherwise, allocates a
  /// new page with the given permissions and returns the physical address of `va` in that page
  /// unless the system is out of memory.
  public mutating func allocate(
    _ va: VirtualAddress, for ps: PagePermissions
  ) -> PhysicalAddress? {
    translate(va, for: ps, handlingFaultWith: { (me, pd) in me.allocate(va, for: ps, in: pd) })
  }

  /// Allocates a new page for mapping `va` with permissions `ps`, updates the page directory entry
  /// `pd` so that it points to the new page, and returns the physical address of the new page.
  ///
  /// This method serves as a page fault handler. `pd` describes the page directory entry in which
  /// the page fault occurred while decoding `va`.
  private mutating func allocate(
    _ va: VirtualAddress, for ps: PagePermissions, in pd: PageDirectoryEntry
  ) -> PhysicalAddress? {
    assert(withUnsafeMainMemory(at: pd.address, read(UInt16.self)) == 0)

    // Look for a free slot in main memory.
    var slot = freeMap.trailingZeroBitCount

    // Is swapping necessary to free one slot?
    if slot >= 16 {
      assert(freeMap == 0)

      // Find slot in secondary memory to swap out the victim.
      let secondary = secondaryMemory.withMemoryRebound(to: UInt64.self, capacity: 16) { (m) in
        for i in 0 ..< 16 {
          let s = m[i].trailingZeroBitCount
          if s < 64 {
            m[i] = m[i] & ~(1 << s)
            return s + (i << 6)
          }
        }
        return Machine.secondaryMemorySlotCount
      }

      // Is secondary memory full?
      if secondary >= Machine.secondaryMemorySlotCount { return nil }

      // Copy the evicted frame to secondary memory and clear the slot in main memory.
      slot = swapVictim(with: UInt16(secondary))
      withUnsafeMutableMainMemory(from: slot << 8, as: UInt8.self) { (m) in
        m.initialize(repeating: 0, count: 256)
      }
    }

    // Update the free map.
    freeMap = freeMap & ~(1 << slot)

    // Compute the physical address of the new page table entry.
    var pa = PhysicalAddress(rawValue: 0)

    // If we reached L2, then `pd` is a leaf and the new page table entry should be written there.
    if pd.level == 2 {
      pa = pd.address
    }

    // Otherwise, we must create new page directories.
    else {
      // Allocate a new directory.
      var lx = kalloc(count: 16)
      withUnsafeMutableMainMemory(at: pd.address, write(lx))

      // If the fault occurred at L0, then `lx` is the address of a L1 directory and we must create
      // a new L2 directory.
      if pd.level == 0 {
        let l2 = kalloc(count: 16)
        let newEntry = PhysicalAddress(
          rawValue: lx.rawValue.advanced(
            by: Int(va.rawValue >> Machine.shifts[0]) & 0x7,
            stridesOf: UInt16.self))
        withUnsafeMutableMainMemory(at: newEntry, write(l2))
        lx = l2
      }

      // At this point, `lx` is the address of a L2 directory.
      pa = PhysicalAddress(
        rawValue: lx.rawValue.advanced(
          by: Int(va.rawValue >> Machine.shifts[1]) & 0x7,
          stridesOf: UInt16.self))
    }

    // Store the new page table.
    withUnsafeMutableMainMemory(at: pa, as: PageTableEntry.self) { (m) in
      var pte = PageTableEntry()
      pte.frame = UInt8(slot)
      pte.isPresent = true
      pte.permissions = ps
      m.initialize(to: pte)
    }

    // Update the frame table
    withUnsafeMutableFrameTable { (m) in
      m[slot].reset()
      m[slot].isReferenced = true
      m[slot].appendBackReference(UInt8(pa.rawValue))
    }

    return translate(va, for: ps, withPageTableEntryAt: pa)
  }

  /// Selects a page to evict, swaps its contents to secondary memory, and returns the index of the
  /// freed frame in main memory.
  private mutating func swapVictim(with slotInSecondaryMemory: UInt16) -> Int {
    precondition(freeMap == 0, "main memory is not full")

    // Look for a "victim" to evict.
    let victim = findVictim()

    // Swap data.
    let p = secondaryMemory
      .advanced(by: Int(slotInSecondaryMemory << 8))
      .assumingMemoryBound(to: UInt64.self)
    withUnsafeMutableMainMemory(from: (victim << 8), as: UInt64.self) { (q) in
      for i in 0 ..< 32 { swap(&p[i], &q[i]) }
    }

    updateAfterSwap(entriesReferringTo: victim, swappedTo: UInt8(slotInSecondaryMemory))
    return victim
  }

  /// Returns the index of the frame storing a page that can be evicted.
  private mutating func findVictim() -> Int {
    withUnsafeMutableFrameTable { (m) in
      var victim = 0xff

      // Look for a "victim", i.e., a frame not referenced since the last stealing pass, favoring
      // candidates with fewer back references.
      for s in 0 ..< 16 {
        // Is `s` ready to be evicted?
        if m[s].isReadyForEviction {
          let n = m[s].backReferenceCount
          if n == 0 {
            return s
          } else if (victim >= 0x80) || (n < m[victim].backReferenceCount) {
            victim = s
          }
        }

        // Otherwise, unset its reference flag and select it tentatively unless it is pinned.
        else {
          m[s].isReferenced = false
          if (victim == 0xff) && !m[s].isPinned {
            victim = 0x80 | s
          }
        }
      }

      // Did we find a frame that wasn't referenced?
      if victim < 0x80 {
        assert((victim & 0xf0) == 0)
        return victim
      }

      // Did we find at least one frame that wasn't pinned?
      else if victim != 0xff {
        assert((victim & 0x70) == 0)
        return victim & 0xf
      }

      // Otherwise, we're out of luck.
      fatalError("cannot evict any frame")
    }
  }

  /// Update the page table entries that are currently referring to `victim`, which is the index of
  /// the frame containing a page whose contents has been swapped out to `secondary`.
  private mutating func updateAfterSwap(
    entriesReferringTo victim: Int, swappedTo secondary: UInt8
  ) {
    var frame = withUnsafeMutableFrameTable { (m) in m[victim] }
    precondition(frame.backReferenceCount <= 2, "not implemented")

    frame.withBackReferences { (rs) in
      for i in 0 ..< rs.count {
        withUnsafeMutableMainMemory(from: Int(rs[i]), as: PageTableEntry.self) { (m) in
          assert(m.pointee.isPresent)
          m.pointee.isPresent = false
          m.pointee.frame = secondary
        }
      }
    }

    frame.removeAllBackReferences()
    withUnsafeMutableFrameTable { (m) in m[victim] = frame }
  }

}

// MARK: Helpers

extension BinaryInteger {

  /// Returns the sum of `self` and `n * s`, where `s` is the stride of `T`.
  fileprivate func advanced<T>(by n: Int, stridesOf: T.Type) -> Self {
    self + Self(n * MemoryLayout<T>.stride)
  }

}

/// Returns a function that returns the value referenced by a pointer to `T`.
private func read<T>(_: T.Type) -> (UnsafePointer<T>) -> T {
  { (p) in p.pointee }
}

/// Returns a function that assigns the memory referenced by a pointer to `newValue`.
private func write<T>(_ newValue: T) -> (UnsafeMutablePointer<T>) -> Void {
  { (p) in p.pointee = newValue }
}
