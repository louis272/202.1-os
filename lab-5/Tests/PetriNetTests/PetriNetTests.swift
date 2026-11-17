import PetriNet
import Testing

@Suite
struct PetriNetTests {

  @Test
  func fireable() {
    let m = model()

    // `t0` is fireable from `(1, 0)`.
    #expect(m.fireable(0, from: [1, 0]))
    // `t0` is not fireable from `(0, 0)`.
    #expect(!m.fireable(0, from: [0, 0]))

    // `t1` is fireable from `(2, 2)`.
    #expect(m.fireable(1, from: [2, 2]))
    // `t1` is not fireable from `(2, 0)`.
    #expect(!m.fireable(1, from: [2, 0]))
  }

  @Test
  func fireableSequence() {
    let m = model()

    #expect(m.fireable([0, 1], from: [1, 1]))
    #expect(!m.fireable([0, 1], from: [0, 1]))
  }

  @Test
  func fire() {
    let m = model()

    // `(2, 2) ->t0 (1, 3)`.
    #expect(m.fire(0, from: [2, 2]) == [1, 3])
    // `(2, 2) ->t1 (3, 2)`.
    #expect(m.fire(1, from: [2, 2]) == [3, 1])
  }

  @Test
  func fireSequence() {
    let m = model()

    #expect(m.fire([0, 1], from: [2, 2]) == [2, 2])
  } 

  /// Returns a simple Petri net.
  func model() -> PetriNet {
    var m = PetriNet(placeCount: 2, transitionCount: 2)
    m[transition: 0, place: 0].consumed = 1
    m[transition: 0, place: 1].produced = 1
    m[transition: 1, place: 0].produced = 1
    m[transition: 1, place: 1].consumed = 1
    return m
  }

  @Test func model_checking() {
    /// Creates a simple Petri net with a lock.
    func model_lock() -> PetriNet {
      var m = PetriNet(placeCount: 3, transitionCount: 4)
      m[transition: 0, place: 0].produced = 1 // t0 -> p0
      m[transition: 0, place: 2].consumed = 1 // p2 -> t0
      m[transition: 1, place: 0].consumed = 1 // p0 -> t1
      m[transition: 1, place: 2].produced = 1 // t1 -> p2
      m[transition: 2, place: 1].produced = 1 // t2 -> p1
      m[transition: 2, place: 2].consumed = 1 // p2 -> t2
      m[transition: 3, place: 1].consumed = 1 // p1 -> t3
      m[transition: 3, place: 2].produced = 1 // t3 -> p2
      return m
    }

    let m = model_lock();

    /// Returns `true` if `m` describes a racy model.
    ///
    /// The result is `true` if both `p0` and `p1` contains a token.
    func isRacy(_ m: Marking) -> Bool {
      m[0] > 0 && m[1] > 0
    }

    if let s = m.sequence(from: [0, 0, 2], toMarkingSatisfying: isRacy(_:)) {
      print("The model shows a data race!")
      print("Here's the proof: \(s)")
    } else {
      print("The model does not show any race.")
    }
  }
}
