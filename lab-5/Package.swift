// swift-tools-version:6.3
import PackageDescription

let package = Package(
  name: "PetriNet",
  products: [
    .executable(name: "pn", targets: ["pn"]),
  ],
  targets: [
    .target(name: "PetriNet"),
    .executableTarget(name: "pn", dependencies: ["PetriNet"]),
    .testTarget(name: "PetriNetTests", dependencies: ["PetriNet"]),
  ])
