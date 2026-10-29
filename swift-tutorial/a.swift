var x = 0
var y = 1

for _ in 0 ..< 10 {
  print(x)
  let z = x + y
  (x, y) = (y, z)
}
