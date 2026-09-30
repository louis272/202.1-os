#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

// MARK: Driver

@main
struct LabSwift {

  static func main() {
    var x = 0
    var y = 1
    print(areNeighbors(&x, &y))

    var p = (0, 1, 3)
    print(areNeighbors(&p.0, &p.1))
    print(areNeighbors(&p.0, &p.2))

    print(nat: 42, radix: 2)
  }

}

// MARK: Library

/// Returns `true` iff `a` and `b` are stored in memory next to each other.
func areNeighbors<T, U>(_ a: inout T, _ b: inout U) -> Bool {
  // TODO
  withUnsafePointer(to: &a) { (p) in
    withUnsafePointer(to: &b) { (q) in
      (p + 1 == q) || (q + 1) == p
    }
  }
}

/// Writes the textual representation of `n` in base `radix` to the standard output.
func print(nat n: UInt32, radix: UInt32 = 10) {
  precondition(radix > 1, "invalid radix")
  // TODO
  let max_nb_bytes: Int = 32    // n is encoded in UInt32 and the smallest radix is '2', so n uses max 32 bytes.
  let buffer_alignment: Int = 1 // UInt8 is stored in 1 byte, so the alignment is 1.
  let buffer_pointer = UnsafeMutableRawPointer.allocate(byteCount: max_nb_bytes, alignment: buffer_alignment)
  
  //var digits: [UInt8] = []
  var m = n
  var idx = max_nb_bytes - 1
  repeat {
    let rest = m % radix
    //digits.append(asciiDigit(representing: rest))
    buffer_pointer.advanced(by: idx).storeBytes(of: asciiDigit(representing: rest), as: UInt8.self)
    m /= radix
    idx -= 1
  } while (m > 0)

  //digits.reverse()

  let out_file: Int32 = 1             // stdout is '1'
  //let nb_bytes: Int = digits.count  // The number of bytes stored in digits. UInt8 is represented on 1 byte.
  //Glibc.write(out_file, &digits, nb_bytes)
  let nb_bytes: Int = max_nb_bytes - idx + 1
  Glibc.write(out_file, buffer_pointer.advanced(by: idx + 1), nb_bytes)

  buffer_pointer.deallocate()
}

// MARK: Helpers

/// Returns the ASCII representation of `n`, which is between `0` and `36`.
func asciiDigit(representing n: UInt32) -> UInt8 {
  if n < 10 { 48 + UInt8(n) } else { 97 + UInt8(n - 10) }
}
