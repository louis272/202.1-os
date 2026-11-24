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
  func fire() {
    let m = model()

    // `(2, 2) ->t0 (1, 3)`.
    #expect(m.fire(0, from: [2, 2]) == [1, 3])
    // `(2, 2) ->t1 (3, 2)`.
    #expect(m.fire(1, from: [2, 2]) == [3, 1])
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

}
