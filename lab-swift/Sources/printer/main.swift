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
  false
}

/// Writes the textual representation of `n` in base `radix` to the standard output.
func print(nat n: UInt32, radix: UInt32 = 10) {
  precondition(n > 1, "invalid radix")
  // TODO
}

// MARK: Helpers

/// Returns the ASCII representation of `n`, which is between `0` and `36`.
func asciiDigit(representing n: UInt32) -> UInt8 {
  if n < 10 { 48 + UInt8(n) } else { 97 + UInt8(n - 10) }
}
