enum List<T> {

  indirect case cons(head: T, tail: List<T>)

  case empty

  func r() -> List<T> {
    func loop(lhs: List<T>, rhs: List<T>) -> List<T> {
      switch lhs {
        case .empty:
          rhs
        case .cons(let h, let t):
          loop(lhs: t, rhs: .cons(head: h, tail: rhs))
      }
    }
    return loop(lhs: self, rhs: .empty)
  }

}

print(List.cons(head: 1, tail: List.cons(head: 2, tail: List.empty)).r())
