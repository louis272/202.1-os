typealias P = (x: Int, y: Int)

struct R {

  var a: P
  var b: P

  var x: Int {
    let w = b.x - a.x
    let h = b.y - a.y
    return abs(w * h)
  }

  static func < (lhs: R, rhs: R) -> Bool {
    lhs.x < rhs.x
  }

}

let r0 = R(a: (0, 0), b: (1, 1))
let r1 = R(a: (1, 1), b: (3, 2))
print(r0 < r1)
