---
title: "Lab 5 -- Petri Nets"
author: [Dr Dimi Racordon]
date: "17.11.2025"
version: "1.0.0"

module: "202"
ue: "202.1"
course: "Operating Systems"

# LaTex specific
fontsize: 10pt
caption-justification: centering
---

<style>
r { color: Red }
y { color: Yellow }
FIXME { color: Yellow }
TODO {color: Blue}
</style>

# Objective

The objective of this laboratory is to familiarize yourself with the semantics of Petri nets.

# Setup

This lab is not platform-specific and can be completed with any installation of Swift 6.3+.
You can follow the official instructions to install Swift on [Linux](https://www.swift.org/install/linux/), [macOS](https://www.swift.org/install/macos/), and [Windows](https://www.swift.org/install/windows/).
Alternatively, you can follow the instructions on [this page](https://docs.swift.org/latest/documentation/userdocs/remote-dev/) to run Swift via a DevContainer.
In any case, **be sure to install Swift 6.3 or higher**!

If your system is properly configured, you should be able to run the following command:

```bash
swift --version
```

If everything is configured properly, you should be able to compile and run the Swift package contained in this directory.
Download (or clone using git) the following repository: [https://github.com/ISC-HEI/202.1-os](https://github.com/ISC-HEI/202.1-os) and navigate to the `lab-4` directory.
Then, run the following commands:

```bash
swift build
swift test
```

# Fire! Fire!

*Looking forward to hearing from you.*

Open the file `Sources/PetriNet/PetriNet.swift`, which implements part of a small library to design and simulate Petri nets, and locate the following functions:

- `fireable(_:)` returns whether a sequence of transition is fireable.
- `fire(_:)` returns the marking obtained after firing a sequence of transitions.

Your goal is to implement these functions, taking inspiration and/or reusing their respective overloads.

To test your result, add new members in `Tests/PetriNetTests/PetriNetTests.swift` that exercise your implementation.
You can run then with the following command:

```bash
swift test
```

# Model checking

Locate the function `sequence(from:toMarkingSatisfying:)`, which returns a sequence of transition leading to a marking satisfying a particular predicate.
This function can be used to implement a rudimentary model checker.
For example:

```swift
/// Creates a simple Petri net with a lock.
func model() -> PetriNet {
  var m = PetriNet(placeCount: 3, transitionCount: 4)
  m[transition: 0, place: 0].produced = 1 // t0 -> p0
  m[transition: 0, place: 2].consumed = 1 // p2 -> t0
  m[transition: 1, place: 0].consumed = 1 // p0 -> t1
  m[transition: 1, place: 2].produced = 1 // t1 -> p2
  m[transition: 2, place: 1].produced = 1 // t2 -> p1
  m[transition: 2, place: 2].consumed = 1 // p2 -> t2
  m[transition: 3, place: 1].consumed = 1 // p1 -> t3
  m[transition: 3, place: 2].produced = 1 // t3 -> p2
}

/// Returns `true` if `m` describes a racy model.
///
/// The result is `true` if both `p0` and `p1` contains a token.
func isRacy(_ m: Marking) -> Bool {
  m[0] > 0 && m[1] > 0
}

if let s = model.sequence(from: [0, 0, 2], toMarkingSatisfying: isRacy(_:)) {
  print("The model shows a data race!")
  print("Here's the proof: \(s)")
} else {
  print("The model does not show any race.")
}
```

Your goal is to implement this functions.

To test your result, add new members in `Tests/PetriNetTests/PetriNetTests.swift` that exercise your implementation.
You can run then with the following command:

```bash
swift test
```
