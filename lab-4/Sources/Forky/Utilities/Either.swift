/// A value that is either an instance of `A` or and instance of `B`.
enum Either<A, B> {

  /// An instance of `A`.
  case left(A)

  /// An instance of `B`.
  case right(B)

}
