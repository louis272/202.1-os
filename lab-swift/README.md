---
title: "Swift for the impatient"
author: [Dr Dimi Racordon]
date: "28.9.2026"
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

The objective of this laboratory is to familiarize yourself with the Swift as a systems programming language.
Specifically, we'll learn about:

- using pointers, and
- calling C functions to interact with the operating system.

# Part 1 -- Setup

In this lab, we will use Swift to call C functions from libc.
Because libc is not a portable library, you will need a Unix system to complete the exercise.
If necessary, you can use a container to emulate such a system.

1. Install [Docker Desktop](https://www.docker.com/) and [Visual Studio Code (VS Code)](https://code.visualstudio.com) on your machine.
2. In VS Code, install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.
3. Download (or clone using git) the following repository: [https://github.com/ISC-HEI/202.1-os](https://github.com/ISC-HEI/202.1-os).
4. Open the `lab-swift` folder of this repository with VS Code and click on "Reopen in Container" in the bottom-right dialogue. If the dialog does not show, you can press `Ctrl+Shift+P` to open the command palette and type "Reopen in Container".
   VS Code will reopen and start a Docker container configured to run Linux on a 64-bit ARM architecture (emulated if necessary).

> Make sure to open the lab folder **directly** to let VS Code detect that a Docker container has been configured.

Whether or not you are using Docker, you can check if your system is ready by compiling the existing code with the following command:

```bash
swift --version
uname
```

The first command should print the version of your Swift installation, which has to be greater than or equal to 6.3.
The second command should print either `Linux` or `Darwin`.

# Part 2 -- Pointers

## Task 1 -- Finding neighbors

Implement the function `areNeighbors(_:_:)`, which returns `true` iff its arguments are stored next to each other in memory.

> Recall that can use the function `withUnsafePointer(to:_:)` to obtain a pointer to variable.

## Task 2 -- Printing numbers

Implement the function `print(nat:radix:)`, which writes the textual representation of an unsigned number to the standard output.
Your implementation **cannot** call printing functions from Swift or C.
It must interact directly with the operating system through libc's thing wrappers.
