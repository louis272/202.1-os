---
title: "Lab 4 -- Forky"
author: [Dr Dimi Racordon]
date: "2.11.2025"
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

The objective of this laboratory is to familiarize yourself with the forking mechanism of Linux.

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
swift run
```

# Forky

Forky is a toy language designed to illustrate the forking mechanism of Linux.
A Forky program is a single term of the following grammar, where `x` denotes variables, `boolean-literal` denotes Boolean literals (i.e., `true` and `false`), and `integer-literal` denotes any integer literal (e.g, `42` or `-2`).

```
e ::=
  boolean-literal
  integer-literal
  x
  e e
  (x) => e
  'let' x = e ; e
  'if' e 'then' e 'else' e
  *e
  *e = e
  *e = 'swap' e 'with' e
  'fork'
  'wait' e
  binary

binary ::=
  e + e
  e - e
  e == e
  e != e
  e < e
  e > e
```

You can run a Forky program using its command-line interpreter:

```bash
swift run forky main.forky
```

*Note: the command `swift run` compiles and run the binary named `forky`. Alternatively, you may compile `forky` first with `swift build` and then run it directly. Binaries compield by Swift Package Manager are found in `.build/debug` or `.build/release`*

A term of the form `(x) => e` declares an anonymous function that takes a single parameter and returns the value computed by `e`.
Function application is expressed by placing two terms next to each others.
For example, the following program evaluates to 2:

```
// A simple function and its application.
((x) => x + 1) 1
```

A term of the form `let x = e1 ; e2` declares a local variable `x` assigned to the result of `e1` and visible in `e2`.
For example, the following program gives a name to the anonymous function defined above:

```
// A simple function bound to a local name.
let increment = (x) => x + 1 ;
increment 1
```

Terms of the form `*e1` and `*e1 = e2` are used to read from and write to memory.
In both cases, `e1` denotes an address between 0 and 1024, expressed as an integer.
For example, `*12` evaluates to the value currently stored at address 12 while `*12 = 3` writes 3 to the storage and that address and evaluates to the value that was previously held there.
The entire memory is initialized to 0 when the program starts.
The following illustrates with a complete program that evaluates to 3.

```
let a = 12 ;
let x = (*a = 3) ;
*a
```

A term of the form `*e1 = swap e2 with e3` performs a so-called *compare-and-swap* update.
The value of `e3` is written at the address computed by `e1` if and only if the current value at that location is equal to that of `e2`.
The result of the term is the value that was read from the location, whether it has changed or not.
The whole operation is performed atomically.

A term of the form `fork` forks the current process.
It evaluates to 0 for the child and to an integer representing the child's identity (i.e., its process identifier) for the parent.
A term of the form `wait e` waits for the completion of the child process identified by `e` and evaluates to the result of tha child.
For example, the following program forks the main process and has the parent wait for the child to perform some computation before resuming.
The whole program evaluates to 3.

```
let increment = (x) => x + 1 ;
let p = fork ;
if p == 0 then increment 2 else increment (wait p)
```

You can see some more program examples in `Examples/`.

# Brains!

Open the file `Sources/Forky/Interpreter.swift`, which implements a virtual machine interpreting Forky programs, and locate the function named `zombies`.
This function is supposed to return the list of zombie processes.
Your objective is to implement it.

To test your result, you can run a Forky program with the option `--zombie`, which will print the identities returned by `Interpreter.zombie` after running a program.

```bash
swift run forky --zombies Examples/memory.forky
```

# Wait with options

On Linux, `wait` is slightly more sophisticated than Forky's implementation.
Your objective is to bring some of these features to Forky.

In `Sources/Forky/Interpreter.swift`, locate the function named `wait`, which implements the semantics of terms having the form `wait e`.
Modify this function such that if `e` is equal to 0, then the process waits for any child having an an identity.

# Concurrent increment

Write a Forky program that increments a shared counter to 100 using using at least two processes.
