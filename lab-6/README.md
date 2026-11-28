---
title: "Lab 6 -- Petri Nets and Liveness"
author: [Dr Dimi Racordon]
date: "24.11.2025"
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
Download (or clone using git) the following repository: [https://github.com/ISC-HEI/202.1-os](https://github.com/ISC-HEI/202.1-os) and navigate to the `lab-6` directory.
Then, run the following commands:

```bash
swift build
swift test
```

# Reachability

Open the file `Sources/PetriNet/PetriNet.swift`, which implements part of a small library to design and simulate Petri nets, and locate the function `states`, which computes the set of states reachable from a particular marking.
Your goal is to implement this function using either a breadth-first or depth-first approach.

To test your result, add new members in `Tests/PetriNetTests/PetriNetTests.swift` that exercise your implementation.
You can run then with the following command:

```bash
swift test
```

# Liveness

In the same file, locate the function `liveness(_:from:)`, which determines the liveness of a particular transition from a given marking.
Your goal is to implement this function.

Recall that liveness can be determined by exploring the strongly connected components of the reachability graph.

To test your result, add new members in `Tests/PetriNetTests/PetriNetTests.swift` that exercise your implementation.
You can run then with the following command:

```bash
swift test
```

# Reachability, concurrently

Taking inspiration from the implementation of `successors(_:)` (in the same file), provide a concurrent implementation that exploits parallelism to speed up the process. You will have to either modify `ReachabilityGraph` to support concurrent updates or accumulate results in a different data structure first.

To test your result, measure the performance of your implementation against the sequential version using the Petri net in `Sources/pn/main.swift`.
