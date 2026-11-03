// swift-tools-version:6.3
import PackageDescription

let package = Package(
  name: "Forky",
  products: [
    .executable(name: "forky", targets: ["Forky"]),
  ],
  targets: [
    .executableTarget(name: "Forky"),
  ])
