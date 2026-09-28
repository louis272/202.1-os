import Foundation

func nextPowerOfTwo(_ a: Int) -> Int {
    var x = 2
    while x < a { x <<= 1 }
    return x
}

print(nextPowerOfTwo(10))

func greatestCommonDivisor(_ a: Int, _ b: Int) -> Int {
    if a == b { a }
    else if a > b { greatestCommonDivisor(a - b, b) }
    else { greatestCommonDivisor(a, b - a) }
}

// func distance(from a: (Int, Int), to b: (Int, Int)) -> Int {
//     let (x0, y0) = a
//     let (x1, y1) = b
//     return Int(sqrt((x0 - x1) * (x0 - x1) + (y0 - y1) * (y0 - y1)))
// }

func longestCommonPrefix(_ a: [Int], _ b: [Int]) -> [Int] {
    var j = 0
    for i in 0 ..< a.count {
        guard (i < b.count) && (a[i] == b[i]) else { break }
        j += 1
    }
    return Array(a[..<j])
}

func reverse(_ xs: inout [Int]) {
    for i in 0 ..< (xs.count >> 1) {
        xs.swapAt(i, xs.count - 1)
    }
}

func removeWhereEven(_ xs: inout [Int]) {
    if xs.isEmpty { return }
    var end = xs.count - 1
    var i = 0
    while i < end {
        if xs[i] & 1 == 0 { 
            xs.swapAt(i, end) 
            end -= 1
        } else { i += 1 }
    }
    xs.remove(at: end)
}

func isPalindrome<T: Equatable>(_ s: [T]) -> Bool {
    if s.count <= 1 { return true }
    for i in 0 ..< ((s.count >> 1)) where (s[i] != s[s.count - i - 1]) {
        return false 
    }
    return true
}

let pal: [Int] = [1, 2, 1]
print(isPalindrome(pal))

func groupByFirst<T: Hashable, U>(_ xs: [(T, U)]) -> [T: [U]] {
    var result: [T: [U]] = [:]
    for (k, v) in xs {
        result[k, default: []].append(v)
    }
    return result
}

// struct MyOptional<T> {
//   var isNil: Bool {}
//   var unwrap: T {}
//   mutating func wrap(_ v: T) {}
// }