// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "mmu",
  platforms: [
    .macOS(.v26),
  ],
  targets: [
    .executableTarget(name: "mmu"),
  ])
