@main
struct Driver {

  static func main() {
    // Create a new machine.
    var machine = Machine()

    // The following 3 virtual addresses are already mapped and represent memory reserved by the
    // kernel. All 3 addresses fall into the same page, which is pinned at 0x0000 in main memory.
    print(machine.translate(0xf800, for: [.read])!)
    print(machine.translate(0xf810, for: [.read])!)
    print(machine.translate(0xf820, for: [.read])!)

    // The following virtual address is not mapped. Address translation raises a segfault.
    if let pa = machine.translate(0x1000, for: [.read]) {
      fatalError("unexpected successful translation of '0x1000' to '\(pa)'")
    }

    // The following virtual address is not mapped. Address translation results in a page fault
    // that is caught to map the address to a newly allocate frame.
    print(machine.allocate(0x0800, for: [.read, .write])!)

    // Now that `0x0800` is mapped, any address within the same page can be translated.
    print(machine.translate(0x0830, for: [.read])!)
    print(machine.translate(0x0840, for: [.read])!)

    // We can also write to the page starting at `0x0800`.
    for (i, c) in "abc".enumerated() {
      let va = VirtualAddress(rawValue: 0x0800 + UInt16(i))
      machine.store(c.asciiValue!, to: va)
      print(UnicodeScalar(machine.load(from: va)))
    }

    // The following allocations will fill up main memory.
    for i in 0 ..< 14 {
      let va = VirtualAddress(rawValue: 0x2000 + UInt16(i << 8))
      print(machine.allocate(va, for: [.read, .write])!)
    }

    // This next allocation will cause swapping.
    print(machine.allocate(0x3000, for: [.read, .write])!)

    // Given the current implementation, we can assume that the page that got evicted was mapped to
    // 0x0100, the frame in which we have written something. Since new pages are zeroed-out, we can
    // now expect to read a 0 from the same location.
    print(machine.load(from: 0x3000))

    // The following translation causes the victim that has been swapped out to be swapped back
    // into main memory, but possibly at a different physical address.
    print(machine.load(from: 0x0800))
  }

}