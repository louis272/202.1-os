/// A binary operator.
enum BinaryOperator: Equatable {

  /// Computes the sum of two operands integer operands.
  case add

  /// Computes the difference between two integer operands.
  case sub

  /// Computes whether the two operands are equal.
  case eq

  /// Computes whether the two operands are inequal.
  case ne

  /// Computes whether the first operand is less than the second.
  case lt

  /// Computes whether the first operand is greater than the second.
  case gt

}
