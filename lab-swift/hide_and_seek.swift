/// Returns the number of bytes between two instances of a type having the given size and alignment
/// requirements, in bytes.
///
/// - Requires: both `size` and `alignment` are greater than 0.
func stride(size: Int, alignment: Int) -> Int {
    precondition(size > 0 && alignment > 0)

    if (size <= alignment) { return alignment }

    return (((size - 1) / alignment) + 1) * alignment
}

func test<T>(_: T.Type) {
  let x = stride(size: MemoryLayout<T>.size, alignment: MemoryLayout<T>.alignment)
  let y = MemoryLayout<T>.stride
  assert(x == y)
}

test(UInt64.self)
test(Double.self)
test(String.self)
test((Int64, Int64, Int8).self)


/// Modifies the internal representation of `x` so that its bytes appear in increasing order when
/// `x` is displayed in hexadeximal.
func sortBytes<T: FixedWidthInteger & UnsignedInteger>(of x: inout T) {
    withUnsafeMutablePointer(to: &x) { (p) in 
        p.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<T>.size) { (q) in 
            var buffer = UnsafeMutableBufferPointer(start: q, count: MemoryLayout<T>.size)
            buffer.sort(by: >)
        }
    }
}

var val1: UInt32 = 0x1a2b3c4d
sortBytes(of: &val1)
print(String(val1, radix: 16)) 

var val2: UInt32 = 0x3c4d1a2b
sortBytes(of: &val2)
print(String(val2, radix: 16))


/// A value that is either an instance of `A` or an instance of `B`.
struct Either<A, B> {

    /// A tagged pointer referring to either an instance of `A` or an instance of `B`.
    private var rawValue: UInt

    /// Creates a value equal to the given instance of `A`.
    init(left: A) { 
        let a: UnsafeMutablePointer<A> = .allocate(capacity: 1)
        a.initialize(to: left)
        rawValue = UInt(bitPattern: a)
        rawValue |= 0b0
    }

    /// Creates a value equal to the given instance of `B`.
    init(right: B) { 
        let b: UnsafeMutablePointer<B> = .allocate(capacity: 1)
        b.initialize(to: right)
        rawValue = UInt(bitPattern: b)
        rawValue |= 0b1
    }
}
