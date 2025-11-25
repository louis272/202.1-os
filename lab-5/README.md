---
title: "Lab 5 -- Files"
author: [Dr Dimi Racordon]
date: "25.11.2025"
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

The objective of this laboratory is to familiarize yourself with the File API of Linux.

The estimated duration of this lab is **2 periods**.
The result of your work must be submitted on [isc.hevs.ch/learn](https://isc.hevs.ch/learn) no later than Sunday 30th November at 23:59 (CEST).

# Setup

You will need a POSIX-compliant [system](https://en.wikipedia.org/wiki/POSIX) as well as a modern C++ compiler to complete this lab.
You can use gcc or clang natively if you are running Linux or macOS.
On Windows, the easiest way to setup your system is to use a Devcontainer, using the instruction below.

1. Install [Docker Desktop](https://www.docker.com/) and [Visual Studio Code (VS Code)](https://code.visualstudio.com) on your machine.
2. In VS Code, install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.
3. Download (or clone using git) the following repository: [https://github.com/ISC-HEI/202.1-os](https://github.com/ISC-HEI/202.1-os).
4. Open the `lab-5` folder of this repository with VS Code and click on "Reopen in Container" in the bottom-right dialogue. If the dialog does not show, you can press `Ctrl+Shift+P` to open the command palette and type "Reopen in Container".
   VS Code will reopen and start a Docker container configured to run Linux on a 64-bit ARM architecture (emulated if necessary).

> Make sure to open the lab folder **directly** to let VS Code detect that a Docker container has been configured.

Whether or not you are using Docker, you can check if your system is ready by compiling the existing code with one of the following command:

If you are using clang:
```bash
clang++ --version
```

If you are using GCC:
```bash
g++ --version
```

In either case, the command should print the version of your C++ compiler.
Since this lab will use fairly old APIs, any reasonably recent version will do.

> You are free to complete this lab on Windows but remember that your submission will be tested on a Unix-like POSIX-compliant plateform.
> Consequently, make sure not to use any Windows-specific function, such as some of those found in `winsock.h`.

# High-level latch

A latch (aka a flip-flop) is a circuit that can store a bit of information and modify its state when it receives a particular signal.
Taking inspiration from this concept, your task is to implement a small TCP server that can store an arbitrary blob of data and release that data before storing a different blob when a connection opens.

More specifically, your task is to use the POSIX API to implement a server application for Unix-like systems that satisfies the following specification:

* The server takes as a command-line argument the name of some text file on which the user has read/write access.
* The server continously listens to incoming connections on the port 5050.
* When a connection is opened, the server waits to receive data from the client.
* Once the client is done sending:
  1. the server sends the contents of the file that was taken as a command-line argument;
  2. the server replaces that contents with the client's data if and only if it received at least one byte; and
  3. the server closes the connection.

For example, assuming the file `fruits.txt` contains the string `apple`, a valid implementation will behave as follows:

```bash
./latch fruits.txt &
echo "orange" | nc localhost 5050
apple
echo "apricot" | nc localhost 5050
orange
echo "melon" | nc localhost 5050
apricot
```

## Task

Implement a server that satisfies the above specification in a file `latch.cc`.
Your program should compile using the following command:

```
c++ -o latch -std=c++23 latch.cc
```

> Note that you do not have to use any C++23 feature.
> Simply keep in mind that your submission will be compiled and teste using the above command.

You can use netcat to test your server as already shown aboce.

## Submission

Once you're done, submit your `latch.cc` file on [isc.hevs.ch/learn](https://isc.hevs.ch/learn).
Your lab will be graded on the basis of the correctness and clarity of your implementation.

## Toubleshooting

If you are using Docker and are unable to connect to your server, it may be because your container is not forwarding ports and/or because VSCode is blocking network traffic.
Try to update your `devcontainer.json` as follows:

```json
{
  "name": "Lightweight Linux",
  "build": {
    "dockerfile": "Dockerfile",
  },
}
```

Further troubleshooting information is available on [this page](https://github.com/orgs/community/discussions/13473).
