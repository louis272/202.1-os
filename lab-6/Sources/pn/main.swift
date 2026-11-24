import PetriNet

func main() async {
  let philosopherCount = 3

  var philosophers = PetriNet(
    placeCount: philosopherCount * 3, transitionCount: philosopherCount * 2)
  var m0 = Marking(Array(repeating: 0, count: philosophers.placeCount))

  for i in 0 ..< philosopherCount {
    let think = i * 2
    let eat = think + 1
    let lhs = philosopherCount * 2 + i
    let rhs = (lhs + 1) % (philosopherCount * 3)

    philosophers[transition: i, place: think].consumed = 1
    philosophers[transition: i, place: lhs].consumed = 1
    philosophers[transition: i, place: rhs].consumed = 1
    philosophers[transition: i, place: eat].produced = 1

    philosophers[transition: i + 1, place: eat].consumed = 1
    philosophers[transition: i + 1, place: lhs].produced = 1
    philosophers[transition: i + 1, place: rhs].produced = 1
    philosophers[transition: i + 1, place: think].produced = 1

    m0[think] = 1
    m0[lhs] = 1
  }

  for (t, m) in await philosophers.successors(m0) {
    print("\(t) -> \(m)")
  }
}

await main()
