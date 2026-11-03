import Foundation

@main struct Command {

  /// The maximum number of steps allowed before the machine is stopped.
  static let fuel = 100_000

   /// The entry point of the command line tool.
  static func main() throws {
    /// The input program.
    var input: String? = nil
    /// `true` iff the identities of the zombie processes should be reported.
    var reportZombies: Bool = false

    // Parse the command-line arguments.
    for a in CommandLine.arguments[1...] {
      if a.starts(with: "--") {
        switch a {
        case "--zombies":
          reportZombies = true
        default:
          try stderr("unknown option '\(a)'")
        }
      } else if input == nil {
        input = a
      } else {
        try stderr("ignoring extraneous input '\(a)'")
        exit(-1)
      }
    }

    if input == nil {
      try stderr("missing input")
      exit(-1)
    }

    // Initialize the machine.
    let program = try parse(String(contentsOfFile: input!))
    var machine = Interpreter(program)

    // Step the machine until the main program exits.
    for _ in 0 ..< fuel {
      if case .exited(let result) = machine.step() {
        print("exited with '\(result)'")
        if reportZombies { print("zombie processes: \(machine.zombies())") }
        return
      }
    }

    // The machine is still processing but we ran out of fuel.
    print("program timed out after \(fuel) steps")
    exit(-1)
  }

  /// Parses `source`.
  private static func parse(_ source: String) throws -> Term {
    do {
      return try Parser.parse(source)
    } catch let e as ParseError {
      try report(e, in: source)
    } catch let e {
      throw e
    }
  }

  /// Reports a diagnostic of `error`, which occurred in `source`, to the standard error and exits
  /// with status code `-1`.
  private static func report(_ error: ParseError, in source: String) throws -> Never {
    let s = source[..<error.span.lowerBound]
    let line = s.count(where: \.isNewline) + 1
    let column = if let i = s.lastIndex(where: \.isNewline) {
      s.distance(from: i, to: s.endIndex)
    } else {
      s.count + 1
    }

    try stderr("at \(line):\(column): \(error)")
    exit(-1)
  }

  /// Writes `message` suffixed by `terminated` to the standard error.
  private static func stderr(
    _ message: String, terminator: String = "\n"
  ) throws {
    var m = message + terminator
    try m.withUTF8({ (s) in try FileHandle.standardError.write(contentsOf: s) })
  }

}
