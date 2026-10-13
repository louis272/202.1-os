---
title: "Lab 3 -- Memory Management"
author: [Dr Dimi Racordon]
date: "12.10.2025"
version: "2.0.0"

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

The objective of this laboratory is to understand how operating systems allocate memory by re-implementing a simplified version of Linux's `mmap` system call.

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

```bash
swift build
swift run
```

# Implementing `mmap`

Open the file `Sources/Machine.swift` and locate the declaration of the function `mmap`.
This declaration describes a simplified version of Linux's `mmap` system call.
Specifically, it only deals with virtual memory and it cannot map the contents of actual files.

The specification of the function is described in its comments.
Your task is to implement its definition.
