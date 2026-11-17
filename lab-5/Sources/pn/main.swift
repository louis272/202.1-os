import PetriNet

func main() {
  // Create a new net and configure its pre/postcondition matrices.
  var net = PetriNet(placeCount: 2, transitionCount: 2)
  net[transition: 0, place: 0].consumed = 1
  net[transition: 0, place: 1].produced = 1
  net[transition: 1, place: 0].produced = 1
  net[transition: 1, place: 1].consumed = 1

  // Check whether `t0` is fireable from `[0, 0]`.
  print(net.fireable(0, from: [0, 0]))

  // Fire `t0` from `[1, 0]`.
  print(net.fire(0, from: [1, 0]))
}

main()
