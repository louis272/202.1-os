func p(until n: Int) -> [Int] {
  var s = Array(repeating: true, count: n)
  s[0] = false
  s[1] = false
  for x in 2 ..< n where s[x] {
    for y in stride(from: x * x, to: n, by: x) {
      s[y] = false
    }
  }
  return (2 ..< n).filter { (i) in s[i] }
}

print(p(until: 100))
