/// The tokens of a program text.
struct Lexer {

  /// The text being tokenized.
  let source: String

  /// The current position of the lexer in `source`.
  var position: String.Index

  /// Creates an instance enumerating the tokens in `source`.
  init(tokenizing source: String) {
    self.source = source
    self.position = source.startIndex
  }

  /// Advances to the next token and returns it, or returns `nil` if no next token exists.
  mutating func next() -> Token? {
    discardWhitespacesAndComments()
    guard let head = peek() else { return nil }

    if let t = takeNumericLiteral() {
      return t
    } else if head.isIdentifierHead {
      return takeKeywordOrIdentifier()
    } else if head.isOperator {
      return takeOperator()
    } else {
      return takePunctuationOrFail()
    }
  }

  /// Returns the next character without consuming it or `nil` if all the input has been consumed.
  private func peek() -> Character? {
    position != source.endIndex ? source[position] : nil
  }

  /// Discards all whitespaces and comments preceding the next token.
  private mutating func discardWhitespacesAndComments() {
    while position != source.endIndex {
      if source[position].isWhitespace {
        discard()
      } else if take("//") != nil {
        discard(while: { (c) in !c.isNewline })
      } else {
        break
      }
    }
  }

  /// Discards `count` characters.
  private mutating func discard(_ count: Int = 1) {
    position = source.index(position, offsetBy: count)
  }

  /// Discards characters until `predicate` isn't satisfied or all the input has been consumed.
  private mutating func discard(while predicate: (Character) -> Bool) {
    _ = take(while: predicate)
  }

  /// Consumes and returns the next character.
  private mutating func take() -> Character {
    defer { position = source.index(after: position) }
    return source[position]
  }

  /// Returns the longest prefix of the input whose characters all satisfy `predicate` and advances
  /// the position of `self` until after that prefix.
  private mutating func take(while predicate: (Character) -> Bool) -> Substring {
    let start = position
    while (position != source.endIndex) && predicate(source[position]) {
      position = source.index(after: position)
    }
    return source[start ..< position]
  }

  /// If the input starts with `prefix`, returns the current position and advances to the position
  /// until after `prefix`. Otherwise, returns `nil`.
  private mutating func take(_ prefix: String) -> String.Index? {
    var newPosition = position
    for c in prefix {
      if newPosition == source.endIndex || source[newPosition] != c { return nil }
      newPosition = source.index(after: newPosition)
    }
    defer { position = newPosition }
    return position
  }

  /// Consumes and returns a numeric literal iff one can be scanned from the character stream.
  private mutating func takeNumericLiteral() -> Token? {
    let p = take("-") ?? position
    let s = take(while: \.isDecimalDigit)

    if s.isEmpty {
      position = p
      return nil
    } else {
      return .init(tag: .int, span: p ..< s.endIndex)
    }
  }

  /// Consumes and returns a keyword or identifier.
  private mutating func takeKeywordOrIdentifier() -> Token {
    let text = take(while: \.isIdentifierTail)
    assert(!text.isEmpty)

    let tag: Token.Tag
    switch text {
    case "else": tag = .else
    case "false": tag = .false
    case "fork": tag = .fork
    case "if": tag = .if
    case "let": tag = .let
    case "then": tag = .then
    case "true": tag = .true
    case "wait": tag = .wait
    default: tag = .identifier
    }

    return .init(tag: tag, span: text.startIndex ..< text.endIndex)
  }

  /// Consumes and returns an operator.
  private mutating func takeOperator() -> Token {
    let text = take(while: \.isOperator)
    assert(!text.isEmpty)

    let tag: Token.Tag
    switch text {
    case "*": tag = .star
    case "=": tag = .assign
    case "=>": tag = .arrow
    case "+": tag = .add
    case "-": tag = .sub
    case "==": tag = .eq
    case "!=": tag = .ne
    case "<": tag = .lt
    case ">": tag = .gt
    default: tag = .error
    }

    return .init(tag: tag, span: text.startIndex ..< text.endIndex)
  }

  /// Consumes and returns punctuation if possible; otherwise consumes a single character and
  /// returns an error token.
  private mutating func takePunctuationOrFail() -> Token {
    let start = position
    let tag: Token.Tag
    switch take() {
    case ";": tag = .semicolon
    case "(": tag = .leftParenthesis
    case ")": tag = .rightParenthesis
    default: tag = .error
    }
    return .init(tag: tag, span: start ..< position)
  }

}

extension Character {

  /// `true` iff `self` is a letter or the underscore.
  fileprivate var isIdentifierHead: Bool {
    self.isLetter || self == "_"
  }

  /// `true` iff `self` is a letter, a decimal digit, or the underscore.
  fileprivate var isIdentifierTail: Bool {
    self.isIdentifierHead || self.isDecimalDigit
  }

  /// `true` iff `self` may be part of an operator.
  fileprivate var isOperator: Bool {
    "<>=+-*/%&|!?^~".contains(self)
  }

  /// `true` iff `self` is a decimal digit.
  fileprivate var isDecimalDigit: Bool {
    asciiValue.map({ (ascii) in (0x30 ... 0x39) ~= ascii }) ?? false
  }

}
