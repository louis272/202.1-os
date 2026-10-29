func subtract<T: Equatable, U: Collection<T>>(_ xs: inout [T], _ ys: U) {
  for y in ys { xs.removeAll(where: { (z) in y == z }) }
}

var xs = [0, 1, 2, 3]
let ys = [1, 2]
subtract(&xs, ys)
print(ys)
