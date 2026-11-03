/// An error that occurred during parsing.
struct ParseError: Error {

  /// The cause of a parse error.
  enum Problem {

    /// The parser expected the construction described in the payload.
    case expected(String)

    /// The parser encountered an undefined symbol.
    case undefined(String)

  }

  /// The cause of the error.
  let problem: Problem

  /// The source code or source position (if empty) identified as the cause of the error.
  let span: Range<String.Index>

  /// Creates an instance reporting `problem` at `site`.
  init(_ problem: Problem, at span: Range<String.Index>) {
    self.problem = problem
    self.span = span
  }

}

extension ParseError: CustomStringConvertible {

  /// A textual description of this error.
  var description: String {
    switch problem {
    case .expected(let s):
      "expected \(s)"
    case .undefined(let s):
      "undefined symbol '\(s)'"
    }
  }

}
