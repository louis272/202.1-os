/// The parsing of a source file.
struct Parser {

  /// The tokens in the input.
  private var tokens: Lexer

  /// The position immediately after the last consumed token.
  private var position: String.Index

  /// The next token to consume, if already extracted from the source.
  private var lookahead: Token?

  /// The names of the variables currently in context.
  private var context: [Substring]

  /// Creates an instance parsing `source`.
  private init(_ source: String) {
    self.tokens = Lexer(tokenizing: source)
    self.position = source.startIndex
    self.lookahead = nil
    self.context = []
  }

  /// Parses `source`.
  static func parse(_ source: String) throws -> Term {
    var p = Parser(source)
    return try p.parseTerm()
  }

  /// Parses a term.
  private mutating func parseTerm() throws -> Term {
    var lhs = try parseAddition()
    while let h = peek(), !h.isTermDelimiter {
      lhs = try .application(lhs, parseTerm())
    }
    return lhs
  }

  /// Parses an infix application whose operator has the same precedence as `+` iff possible,
  /// otherwise; parses the operand of such an application.
  private mutating func parseAddition() throws -> Term {
    var lhs = try parseComparison()
    while let o = take(anyOf: [.add, .sub]) {
      let rhs = try parseTerm()
      lhs = .binary(BinaryOperator(o.tag)!, lhs, rhs)
    }
    return lhs
  }

  /// Parses an infix application whose operator has the same precedence as `==` iff possible,
  /// otherwise; parses the operand of such an application.
  private mutating func parseComparison() throws -> Term {
    var lhs = try parseSimple()
    while let o = take(anyOf: [.eq, .ne]) {
      let rhs = try parseTerm()
      lhs = .binary(BinaryOperator(o.tag)!, lhs, rhs)
    }
    return lhs
  }

  /// Parses a simple term.
  private mutating func parseSimple() throws -> Term {
    let head = try peek() ?? expected("expression")

    switch head.tag {
    case .true, .false:
      discard() ; return .bool(tokens.source[head.span] == "true")
    case .int:
      discard() ; return .int(Int(tokens.source[head.span])!)
    case .fork:
      discard() ; return .fork
    case .identifier:
      return try parseIdentifier()
    case .if:
      return try parseConditional()
    case .let:
      return try parseLet()
    case .star:
      return try parseReadOrWrite()
    case .wait:
      return try parseWait()
    case .leftParenthesis:
      return try parseAbstractionOrParenthesizedTerm()
    default:
      throw expected("expression")
    }
  }

  /// Parses an identifier.
  private mutating func parseIdentifier() throws -> Term {
    let head = try take(.identifier) ?? expected("identifier")
    return try .variable(debruijn(head))
  }

  /// Parses a conditional.
  private mutating func parseConditional() throws -> Term {
    let _ = try take(.if) ?? expected("'if'")
    let a = try parseTerm()
    let _ = try take(.then) ?? expected("'then'")
    let b = try parseTerm()
    let _ = try take(.else) ?? expected("'else'")
    let c = try parseTerm()
    return .conditional(if: a, then: b, else: c)
  }

  /// Parses a let binding.
  private mutating func parseLet() throws -> Term {
    let _ = try take(.let) ?? expected("'let'")
    let n = try take(.identifier) ?? expected("identifier")
    let _ = try take(.assign) ?? expected("'='")
    let x = try parseTerm()
    let _ = try take(.semicolon) ?? expected("';'")

    context.append(tokens.source[n.span])
    defer { context.removeLast() }
    let y = try parseTerm()

    return .application(.abstraction(y), x)
  }

  /// Parses a read or write term.
  private mutating func parseReadOrWrite() throws -> Term {
    let _ = try take(.star) ?? expected("'*'")
    let a = try parseTerm()
    if take(.assign) == nil {
      return .read(from: a)
    } else {
      let e = try parseTerm()
      return .write(e, to: a)
    }
  }

  /// Parses a write term.
  private mutating func parseWrite() throws -> Term {
    let _ = try take(.wait) ?? expected("'!'")
    let e = try parseTerm()
    let _ = try take(.assign) ?? expected("'='")
    let a = try parseTerm()
    return .write(e, to: a)
  }

  /// Parses a wait term.
  private mutating func parseWait() throws -> Term {
    let _ = try take(.wait) ?? expected("'wait'")
    let e = try parseTerm()
    return .wait(e)
  }

  /// Parses a an abstraction iff possible; otherwise, parses a parenthesized term.
  private mutating func parseAbstractionOrParenthesizedTerm() throws -> Term {
    let _ = try take(.leftParenthesis) ?? expected("'('")

    let backup = self
    var x = try take(.identifier).map(Either.left) ?? Either.right(parseTerm())

    // If the next token is not a right parenthesis, then it may be that we have parsed part of a
    // term rather than just an identifier or parameter.
    if take(.rightParenthesis) == nil {
      self = backup
      x = try .right(parseTerm())
      let _ = try take(.rightParenthesis) ?? expected("')'")
    }

    switch x {
    case .left(let n) where take(.arrow) != nil:
      context.append(tokens.source[n.span])
      defer { context.removeLast() }
      let e = try parseTerm()
      return .abstraction(e)

    case .left(let n):
      return try .variable(debruijn(n))

    case .right(let e):
      return e
    }
  }

  /// Returns the De Bruijin index of the variable named `n` in the current context.
  private func debruijn(_ n: Token) throws -> Int {
    let s = tokens.source[n.span]
    if let i = context.firstIndex(of: s) {
      return context.count - i - 1
    } else {
      throw ParseError(.undefined(String(s)), at: n.span)
    }
  }

  /// Returns the next token without consuming it.
  private mutating func peek() -> Token? {
    if let n = lookahead {
      return n
    } else if let n = tokens.next() {
      lookahead = n
      return n
    } else {
      return nil
    }
  }

  /// Returns `true` iff the next token has tag `k`, without consuming that token.
  private mutating func next(is k: Token.Tag) -> Bool {
    peek()?.tag == k
  }

  /// Returns `true` iff the next token's tag is contained in `ks`, without consuming that token.
  private mutating func next<T: Sequence<Token.Tag>>(anyOf ks: T) -> Bool {
    peek()?.isAnyOf(ks) ?? false
  }

  /// Discards the next token, if any.
  private mutating func discard() {
    _ = take()
  }

  /// Consumes and returns the next token.
  private mutating func take() -> Token? {
    lookahead.take() ?? tokens.next()
  }

  /// Consumes and returns the next token iff it has tag `k`.
  private mutating func take(_ k: Token.Tag) -> Token? {
    next(is: k) ? take() : nil
  }

  /// Consumes and returns the next token iff its tag is contained in `ks`.
  private mutating func take<T: Sequence<Token.Tag>>(anyOf ks: T) -> Token? {
    next(anyOf: ks) ? take() : nil
  }

  /// Returns a parse error reporting that `s` was expected at the current position.
  private func expected(_ s: String) -> ParseError {
    expected(s, at: position ..< position)
  }

  /// Returns a parse error reporting that `s` was expected at `site`.
  private func expected(_ s: String, at site: Range<String.Index>) -> ParseError {
    .init(.expected(s), at: site)
  }

}

extension Optional {

  /// Returns the value wrapped in `optional` or throws `error` if `optional` is `nil`.
  fileprivate static func ?? (lhs: Self, rhs: @autoclosure () -> ParseError) throws -> Wrapped {
    if let v = lhs { v } else { throw rhs() }
  }

}

extension BinaryOperator {

  /// Creates an instance denoting the operator expressed by `t`.
  init?(_ t: Token.Tag) {
    switch t {
    case .add : self = .add
    case .sub : self = .sub
    case .eq  : self = .eq
    case .ne  : self = .ne
    case .lt  : self = .lt
    case .gt  : self = .gt
    default:
      return nil
    }
  }

}
