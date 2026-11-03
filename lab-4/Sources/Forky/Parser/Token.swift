/// A terminal symbol of the syntactic grammar.
struct Token {

  /// The tag of a token.
  enum Tag {

    // Errors.
    case error

    // Identifiers and keywords.
    case identifier
    case `else`
    case `false`
    case `fork`
    case `if`
    case `let`
    case `star`
    case `then`
    case `true`
    case `wait`

    // Scalar literals.
    case int

    // Operators.
    case arrow
    case assign
    case add
    case sub
    case eq
    case ne
    case lt
    case gt

    // Punctuation.
    case semicolon
    case leftParenthesis
    case rightParenthesis

  }

  /// The tag of the token.
  let tag: Tag

  /// The site from which `self` was extracted.
  let span: Range<String.Index>

  /// `true` iff `self` occurs immediately after a term.
  var isTermDelimiter: Bool {
    isAnyOf([.rightParenthesis, .semicolon, .assign, .then, .else])
  }

  /// Returns `true` iff `self`'s tag is contained in `ks`.
  func isAnyOf<T: Sequence<Token.Tag>>(_ ks: T) -> Bool {
    ks.contains(tag)
  }

}
