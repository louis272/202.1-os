/// The liveness of a transition in a Petri net, from a particular marking.
public enum TransitionLiveness: Hashable, Sendable {

  /// The transition is never fireable.
  case dead

  /// The transition is fireable at least once.
  case quasiLive

  /// The transition is always eventually fireable.
  case live

}
