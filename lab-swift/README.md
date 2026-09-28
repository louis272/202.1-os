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

Swift is an open source general purpose programming language developed by Apple.
While the primary goal of Swift was to replace Objective-C for the development of macOS and iOS applications, it has since gained popularity in other domains, including systems programming.

The objective of this laboratory is to familiarize yourself with the Swift.
Specifically, we'll learn about:

- simple data structures,
- control flow,
- functions, methods, and subscripts,
- protocols and extensions, and
- pointers.

# Part 1 -- Setup

This lab is not platform-specific and can be completed with any installation of Swift 6.3+.
You can follow the official instructions to install Swift on [Linux](https://www.swift.org/install/linux/), [macOS](https://www.swift.org/install/macos/), and [Windows](https://www.swift.org/install/windows/).
Alternatively, you can follow the instructions on [this page](https://docs.swift.org/latest/documentation/userdocs/remote-dev/) to run Swift via a DevContainer.
In any case, **be sure to install Swift 6.3 or higher**!

If your system is properly configured, you should be able to run the following command:

```bash
swift --version
```

You may also want to try to compile and run a Swift program.
The following commands should write "Hello, World!" to your terminal.

```bash
echo 'print("Hello, World!")' > hello.swift
swift hello.swift
```

If nothing works and you are in a pinch, follow along with someone else or use [compiler explorer](https://compiler-explorer.com).

# Part 2 -- Tutorial

This tutorial presents the most important notions of Swift.
It is essentially a condensed version of the official (and excellent) [language guide](https://docs.swift.org/latest/documentation/the-swift-programming-language).
It is certainly **not** exhaustive.

All notions are introduced in a consistent order, and illustrated with a lot of examples that incrementally build a small Pokemon simulator.
You probably know about most of the information in this tutorial already.
Nonetheless, it may be useful to go over it just to get a sense of how things work.

Unless stated otherwise, all the code snippets can be copy/pasted into the Swift REPL.
Just run the command `swift repl` in a terminal to get it.

## Constants, variables, and types

The Swift programming language distinguishes variables and constants.
Both are an association between a name and a value.
Variables can have their value modified, whereas constants cannot.

Variables are declared with the keyword `var`.
They can be affected a new value using the `=` operator.

```swift
var pokemonLevel = 1
pokemonLevel = 2
```

Constants are declared with the keyword `let`.
Unlike variables, it is not possible to assign a value to a constant after its initialization.

```swift
let pokemonSpecies = "Bulbasaur"
pokemonSpecies = "Pikachu"
// error: cannot assign to value: 'pokemonSpecies' is a 'let' constant
```

> Always use the most restrictive construct by default, for instance `let` instead of `var`.
> In practice, it will help avoid some bugs.

The value of variable and constants can be printed with the built-in function `print(_:)`:

```swift
var pokemonLevel = 1
print(pokemonLevel)
// 1
```

> We'll discuss functions (and methods) with their syntax and semantics at length later in this tutorial.
> For the time being, just use them as presented in the examples.

Values can be included in strings by wrapping them in within `\()`.
This feature is called [string interpolation](https://docs.swift.org/latest/documentation/the-swift-programming-language/stringsandcharacters/#String-Interpolation).

```swift
print("The level of my Pokemon is \(pokemonLevel).")
// The level of my Pokemon is 1.
```

From now on, we will use the term "variables" to talk about both constant introduced with `let` and variables introduced with `var`.

### Types

The previous examples do not specify information what can be stored in a variable or constant, but the Swift compiler prevents putting arbitrary values in variables or constants.
For instance, it is impossible to put a floating point number into a variable that has been initialized with an integer:

```swift
var pokemonLevel = 1
pokemonLevel = 2.3
// error: cannot assign value of type 'Double' to type 'Int'
```

Swift is strongly typed.
Every variable is given a unique type, and can only store values that correspond to this type.
Weakly typed languages do not have this restriction. Static typing also helps to ensure [type safety](https://en.wikipedia.org/wiki/Type_safety).

The type of a variable may not be explicit, but it always exists.
Swift provides type inference. If the compiler can infer the type of a variable (or constant) using its initialization, it automatically associates this type with the variable.

It is sometimes necessary to explicitly specify the type of a variable, with what is called type annotations.
In the example below, the variable `pokemonWeight` is explicitly typed with `Double` (for double precision floating point number), which tells Swift that it should consider it as a `Double` value:

```swift
let pokemonWeight: Double = 5.1
```

Using type annotations, it is possible to declare a constant and initialize it later.
This feature is not available in the REPL, but available in compiled code:

```swift
// Note: does not work in REPL mode.
let pokemonWeight: Double
pokemonWeight = 5.1
```

It is possible to declare multiple variables of the same type on a single line:

```swift
let x, y: Int
```

> 👎🏻 Note that this should be done sparingly and **only when the variables are clearly related**.

The type of an expression can be retrieved with the built-in function `type(of:)`:

```swift
let pokemonWeight: Double = 5.1
print(type(of: pokemonWeight))
// Double
print(type(of: "Pikachu"))
// String
```

### Optionals

Swift requires to initialize all variables (or constants) with a value, because it does not allow them to be `nil` by default.
Allowing everywhere the [null pointer](https://en.wikipedia.org/wiki/Null_pointer) is a bad programming practice, as it creates easily errors.

Instead, Swift provide [optional types](https://developer.apple.com/documentation/swift/optional) to explicitly state what can be null.
An optional type denotes a value that may be present or not.
It is specified by appending the operator `?` to any type. The original type is wrapped with the possibility of the `nil` value:

In the following example, since no value is provided for `x`, the language automatically creates an initialization with the special `nil` value, that denotes the absence of a value.
It is also possible to assign `nil` manually.
Values can be assigned to optionals the same way they would have been assigned to the original type.

```swift
var trainer1: String?
// trainer1: String? = nil
var trainer2: String? = nil
// trainer2: String? = nil
var trainer3: String? = "Ash"
// trainer3: String? = "Ash"
```

Optional types take part in type safety.
Their use is not transparent: it differs from non-optionals.
Assignment to another variable requires that the other variable is also an optional.

```swift
var trainer1: String? = "Ash"
// trainer1: String? = "Ash"
var trainer2: String = trainer1
// error: value of optional type 'String?' not unwrapped; did you mean to use '!' or '?'?
var trainer3 = trainer1
// trainer3: String? = "Ash"
```

Any optional can be converted to a non-optional value using the `!` operator.
Swift returns the wrapped value if it exists, or throws an error at runtime if the optional value is `nil`.
This operation is called forced-unwrapping:

```swift
var trainer1: String? = "Ash"
// trainer1: String? = "Ash"
var trainer2: String = trainer1!
// trainer2: String = "Ash"
trainer1 = nil
trainer2 = trainer1!
// fatal error: unexpectedly found nil while unwrapping an Optional value
```

> 👎 You should never force-unwrap an optional unless your algorithm makes sure it will be assigned to a value before you do it.
> We'll see a way to do that later.

Another way to handle optional variables is use the infix operator `??`.
It returns its left part if it has a value, and is thus a non-optional or a non-nil optional; and retuns its right part in the other cases.
This operator is used mainly to provide a default value when using optional variables:

```swift
let trainer3 = trainer1 ?? "Brock"
```

### Tuples

A [tuple](https://en.wikipedia.org/wiki/Tuple) is a container composed of two or more values.
It is a kind of record data structure.
It can be initialized with a comma-separated list of values, enclosed in parentheses.
A tuple type is a Cartesian product of as many types as needed.

```swift
let bulbasaur = (001, "Bulbasaur")
```

> Unlike some other languages, adding padding zeros doesn't have any effect in Swift.
> To seize numbers in binary, octal or hexadecimal, prefix your number with respectively `0b`, `0o` and `0x`.

Type inference makes sure that the bulbasaur constant is typed consistently with the tuple type `(Int, String)`.
Nevertheless, tuples can be explicitly typed using a comma-separated list of types, enclosed in parentheses.
This can prove useful when the variable is not initialized on declaration:

```swift
// Note: does not work in REPL mode.
let bulbasaur: (Int, String)
bulbasaur = (001, "Bulbasaur")
```

Assignment of a tuple value to a tuple variable must be valid with respect of typing, as all other assignments.

```swift
var pokemon = (001, "Bulbasaur")
pokemon = (002, "Ivysaur")
pokemon = ("Venusaur", 003)
// error: cannot assign value of type 'String' to type 'Int'
```

The values of a tuple are accessed by suffixing a tuple expression with `.n`, where `n` is the `n`-th value of the tuple (starting at 0):

```swift
bulbasaur.1
// $R1: String = "Bulbasaur"
```

Tuples are an easy way to pack data together, but relying on the position within the tuple is a bad programming practice.
To make the code clearer and less error-prone, the parts of a tuple can be labeled.
As a result, they can be accessed using their labels rather than their position in the tuple.
However, positional access is still possible, as Swift stores both the position and the label for tuples:

```swift
let bulbasaur = (number: 001, name: "Bulbasaur")
// bulbasaur: (number: Int, name: String) = {
//   id = 1
//   name = "Bulbasaur"
// }
bulbasaur.1
// $R1: String = "Bulbasaur"
bulbasaur.name
// $R2: String = "Bulbasaur"
```

Another way to retrieve the values of a tuple is to assign them to new variables (or constants).
This process is called decomposition:

```swift
let bulbasaur = (number: 001, name: "Bulbasaur")
let (pokemonId, pokemonName) = bulbasaur
// pokemonId: Int = 1
// pokemonName: String = "Bulbasaur"
```

If some values aren't needed, they can be explicitly ignored by using _ when decomposing the tuple:

```swift
let bulbasaur = (number: 001, name: "Bulbasaur")
let (_, pokemonName) = pokemon
// pokemonName: String = "Bulbasaur"
```

Tuple types (as well as other types) can become quite wordy.
Thanks to type inference, defining the tuple type is implicit in most situations.
But as we have seen, explicit typing is sometimes still required.
In order to avoid writing several times the same type (at different places in the code), it is possible to create type aliases:

```swift
typealias Species = (number: Int, name: String)
let bulbasaur: Species = (001, "Bulbasaur")
let ivysaur  : Species = (number: 002, name: "Ivysaur")
```

> Notice that we can omit the labels when initializing the bulbasaur constant.
> That is possible only if the values are in the same order as in the tuple definition.

### Enumerations

An enumeration defines a set of possible values for a type.
It can also be named [tagged union](https://en.wikipedia.org/wiki/Tagged_union) or a sum type in other programming languages.
An enumeration is used to represent types that can have a fixed set of possible contents.
Enumerations are not possible if the set of possible contents can be extended, for instance by the user.
They must be fully defined in only one place of the soure code.

An enumeration type is declared using the keyword `enum`, and its different values with the keyword `case`:

```swift
enum SpeciesType {
  case grass
  case fire
  case water
}
```

It is also possible to declare the cases of an enumeration on a single line:

```swift
enum SpeciesType {
  case grass, fire, water
}
```

> An enumeration is a type. By convention, all type names start with a capital letter (`Int`, `String`, etc.) and so should enumerations.
> The name of an enumeration should also be singular rather than plural, so that its use makes more sense in the code.

A variable of an enumeration type can only be of one of the enumeration cases.
Assignment is written using the qualified name of the case:

```swift
let bulbasaurSpeciesType = SpeciesType.grass
// bulbasaurSpeciesType: SpeciesType = grass
```

If the type of the variable is explicitly defined or has already been inferred, it is possible (and preferred) to omit the name of the enumeration:

```swift
let bulbasaurSpeciesType: SpeciesType
bulbasaurSpeciesType = .grass
// bulbasaurSpeciesType: SpeciesType = grass
```

Enumeration cases can store associated values, which can be used to add information to particular cases:

```swift
enum Consumable {
  case pokeball(catchRateMultiplier: Double)
  case potion(restoration: Int)
}
let ultraBall = Consumable.pokeball(catchRateMultiplier: 2)
```

Beware that the above `ultraBall` constant is of type `Consumable`.
It is thus not possible to directly consider it as a `pokeball` and access its `catchRateMultiplier`.
This tutorial explains later how to obtain such information.

```swift
ultraBall.catchRateMultiplier
// error: value of type 'Consumable' has no member 'catchRateMultiplier'
```

Enumeration types can be recursive.
This is very useful for naturally recursive data structures, such as lists or trees.
A recursive enumeration must be prefixed with the keyword indirect:

```swift
indirect enum BinaryTree {
  case leaf
  case node(BinaryTree, BinaryTree)
}
let aTree : BinaryTree = .node(.leaf, .node(.leaf, .leaf))
```

Enumerations are a powerful tool in Swift, and there is much more to talk about.
More detailed information and examples are available in [the language guide](https://docs.swift.org/latest/documentation/the-swift-programming-language/enumerations/).

### Arrays

An [array](https://developer.apple.com/documentation/swift/array) is a sequence of values of homogeneous type (e.g. a collection of `String` values).
Arrays are declared with square brackets `[]`:

```swift
let species = [(001, "Bulbasaur"), (004, "Charmander"), (007, "Squirtle")]
```

Type inference considers this array as an array of tuples `(Int, String)`, as we have put values of such tuples within.
It also handles tuples with named fields, for instance:

```swift
let species = [(number: 001, name: "Bulbasaur"), (number: 004, name: "Charmander"), (number: 007, name: "Squirtle")]
```

If the values of an array are not given on initialization, or if the array is initially empty, it is necessary to explicitly type the array.
This behavior is similar to the declaration of any variable, and more precisely similar to how optionals work.

```swift
let species = []
// error: empty collection literal requires an explicit type
typealias Species = (number: Int, name: String)
let species: [Species]
```

An empty array can be initialized with explicit type annotation using the following syntax:

```swift
let species: [Species] = []
```

Arrays are collections: they are indexed by `Int` values, starting at 0.
Their values can be accessed by subscripting the array (i.e. using the square brackets `[]`) with the desired index.
Using a negative number or an index equal to or greater than the size of the array will trigger a runtime error:

```swift
let species: Species = [(001, "Bulbasaur"), (004, "Charmander"), (007, "Squirtle")]
species[1].name
// $R0: String = "Charmander"
species[3].name
// fatal error: Index out of range
```

Slices are subparts of an array.
They are themselves considered collections.
They can be accessed using a range rather than an `Int` value as the index of the subscript:

```swift
species[0 ... 1]
// $R1: ArraySlice<(number: Int, name: String)> = 2 values {
//   [0] = {
//     id = 1
//     name = "Bulbasaur"
//   }
//   [1] = {
//     id = 4
//     name = "Charmander"
//   }
// }
species[1 ... 2][1].name
// $R2: String = "Charmander"
```

> The first index of a slice is the index coincides with the position of its first element in the array.
> That is not always 0!

The number of elements in an array is obtained by its `count` property:

```swift
species.count
// $R6: Int = 3
```

> Trying to access or modify a value for an index that is outside of an array's existing bounds will trigger a runtime error.
> Except when the array is empty, its valid indices are always comprised between 0 and the its number of elements (its `count` property) minus one.

Notice that in all the examples above, the `species` array was declared as a constant (using the keyword `let`).
As a result, it is an immutable collection. It is impossible to add or remove values to it, or to change the value at a given index:

```swift
let species: Species = [(001, "Bulbasaur"), (004, "Charmander"), (007, "Squirtle")]
species[0] = (number: 025, name: "Pikachu")
// error: cannot assign through subscript: 'species' is a 'let' constant
```

Mutable arrays have to be declared with the `var` keyword:

```swift
var species = [(number: 001, name: "Bulbasaur"), (number: 004, name: "Charmander"), (number: 007, name: "Squirtle")]
species[3] = (number: 025, name: "Pikachu")
species[3].name
// $R0: String = "Pikachu"
species[1 ... 2] = [(number: 043, name: "Oddish"), (number: 016, name: "Pidgey")]
species
// $R1: [(number: Int, name: String)] = 3 values {
//   [0] = {
//     id = 25
//     name = "Pikachu"
//   }
//   [1] = {
//     id = 43
//     name = "Oddish"
//   }
//   [2] = {
//     id = 16
//     name = "Pidgey"
//   }
// }
```

Inserting a new value in an array is not possible to use the subscript assignment.
Instead, the user must use the `Array.insert(_:at:)` function.
It inserts a new element at the specified position and moves all remaining elements one position after:

```swift
species[3] = (number: 025, name: "Pikachu")
// fatal error: Index out of range
species.insert((number: 043, name: "Oddish"), at: 0)
species
// $R1: [(number: Int, name: String)] = 4 values {
//   [0] = {
//     id = 43
//     name = "Oddish"
//   }
//   [1] = {
//     id = 25
//     name = "Pikachu"
//   }
//   [2] = {
//     id = 43
//     name = "Oddish"
//   }
//   [3] = {
//     id = 16
//     name = "Pidgey"
//   }
// }
```

Similarly, removing a value is performed with the `Array.remove(at:)` function.
It removes the element at the specified position and moves all remaining elemennts one position before:

```swift
species.remove(at: 1)
species
// $R1: [(number: Int, name: String)] = 3 values {
//   [0] = {
//     id = 43
//     name = "Oddish"
//   }
//   [1] = {
//     id = 43
//     name = "Oddish"
//   }
//   [2] = {
//     id = 16
//     name = "Pidgey"
//   }
// }
```

### Sets

A [set](https://developer.apple.com/documentation/swift/set) is a collection of values of homogeneous type.
Unlike arrays, sets are not ordered, and can contain at most one instance of each value. Swift does not provide a dedicated syntax for sets: they are written as arrays and explicitly typed as sets.

```swift
let speciesNames: Set = ["Bulbasaur", "Charmander", "Squirtle"]
```

> Notice that the only difference with the syntax to declare an array is the explicit typing `: Set`.
> Behind the scenes, the type `Set` is defined so that it can be initialized with the same syntax as arrays.
> This process is called literal initialization.
> The explicit typing allows Swift to know that it must use the initializer of `Set` rather than that of `Array`.

If the set is declared before its initialization, or is initially empty, the type of its values must also be defined explicitly.
The syntax is similar to the one used for arrays:

```swift
let speciesNames: Set<String> = []
```

> Notice that if we write `Set<Species>`, the compiler would complain about the `Species` type not conforming to the `Hashable` protocol.
> That is because the elements of a set must have some properties that our type `Species` doesn't have.
> We'll see later how we can extend a type to make it respect such properties.

As arrays, sets are immutable if declared with `let`, and mutable if declared with `var`.
They also define similar `Set.insert(_:)` and `Set.remove(_:)` functions, and the `count` property.
A call to `remove(_:)` does not change anything if the value does not belong to the set.

```swift
var speciesNames: Set = ["Bulbasaur", "Charmander", "Squirtle"]
speciesNames.insert("Pidgey")
speciesNames.count
// $R0: Int = 4
speciesNames.remove("Pidgey")
speciesNames.count
// $R0: Int = 3
```

### Dictionaries

A [dictionary](https://developer.apple.com/documentation/swift/dictionary) is a mapping from keys to values.
Each key is associated with exactly one value or nothing.
Like a set, a key cannot appear more than once in a dictionary.
A same value can however be associated with multiple keys. Dictionaries are written as a comma-separated list of key-value pairs `k: v`, where `k` is a key and `v` its associated value:

```swift
enum SpeciesType { case grass, fire, water }
let speciesTypes = ["Bulbasaur": SpeciesType.grass, "Charmander": SpeciesType.fire]
```

If the dictionary is declared before its initialization, or is initially empty, the type of its keys and values must be defined explicitly.
The syntax is similar to the one used for arrays and sets:

```swift
let speciesTypes: [String: SpeciesType] = [:]
```

Dictionaries are indexed by their keys.
That differs from arrays that are indexed by integers.
The values of a dictionary can be accessed by subscripting the dictionary, using the square brackets `[]`, with the desired key.

```swift
enum SpeciesType { case grass, fire, water }
let speciesTypes = ["Bulbasaur": SpeciesType.grass, "Charmander": SpeciesType.fire]
speciesTypes["Bulbasaur"]
// $R0: SpeciesType? = grass
```

Notice that the result is an optional.
The values returned by dictionary subscripts are optionals, because the `nil` value is returned if the key does not exist.
This behavior differs from arrays, that raise an error in case of access outside the indices.
If the user knows that the key exists, the `!` operator can be used to get a non-optional value:

```swift
speciesTypes["Bulbasaur"]!
// $R0: SpeciesType = grass
```

As arrays and sets, dictionaries are mutable if declared with `var` and constants if declared with `let`.
Modification of the value associated to a key is similar to arrays and sets:

```swift
enum SpeciesType { case grass, fire, water }
var speciesTypes = ["Bulbasaur": SpeciesType.grass, "Charmander": SpeciesType.fire]
speciesTypes["Bulbasaur"] = .water
```

Insertion and deletion differ from arrays and sets, as they are possible using subscripts:

```swift
enum SpeciesType { case grass, fire, water }
var speciesTypes = ["Bulbasaur": SpeciesType.grass, "Charmander": SpeciesType.fire]
speciesTypes["Oddish"] = .grass
speciesTypes["Charmander"] = nil
```

### Structs

Structs are [record types](https://en.wikipedia.org/wiki/Record_(computer_science)).
They allow to group together data.
They are similar to tuples with labels, but have much more powerful features that will be seen later.

A struct is declared with the keyword `struct`, and contains typed properties declared as variables or constants:

```swift
typealias Species = (number: Int, name: String)
struct Pokemon {
  let species: Species
  var level: Int
}
```

Notice that unlike tuples, this type definition specifies whether each property is a variable or a constant.
This distinction defines what is mutable or immutable once the struct is initialized:

```swift
var rainer = Pokemon(species: (number: 134, name: "Vaporeon"), level: 58)
let sparky = Pokemon(species: (number: 135, name: "Jolteon"), level: 31)
```

> Swift provides a default initializer for the `Pokemon` struct, as there is none explicitly defined.
> This initializer is called memberwise initializer, and requires to define values for all properties of the struct.
> We will see later how to declare custom initializers.

The `Pokemon` struct initializer is used to initialize the `rainer` variable, which in turn initializes the properties of the struct (namely `species` and `level`).
Accessing the properties of a type instance (e.g. a struct instance) is performed using the dot syntax:

```swift
rainer.level
// $R0: Int = 58
```

The property `rainer.level` can be mutated, as the `rainer` is a `var` and the `level` property is also a var.
On the contrary, it is impossible to assign `rainer.species`, because the property is a `let`, or to assign `sparky.level`, because `sparky` is a `constant`.
If a struct is initialized as a constant, then none of its properties can be mutated, no matter how they were declared:

```swift
rainer.level = rainer.level + 1
rainer.level
// $R0: Int = 59
rainer.species = (number: 001, name: "Bulbasaur")
// error: cannot assign to property: 'species' is a 'let' constant
sparky.level = sparky.level + 1
// error: cannot assign to property: 'sparky' is a 'let' constant
```

Note that if the instance is wrapped into an optional types, its properties can be accessed via optional chaining:

```swift
var rainer: Pokemon? = Pokemon(species: (number: 134, name: "Vaporeon"), level: 58)
rainer?.level
// $R0: Int? = 58
```

Notice that the return value of an optional chaining is an optional type, wrapping the requested property.
The reason is that if the first optional is `nil`, the result of the expression will also be `nil`, but typed as an optional of the expected value:

```swift
rainer = nil
rainer?.level
// $R0: Int? = nil
```

Optional chaining also allows to safely assign the property of an instance wrapped in an optional.
If the value is present, its property will be set, otherwise nothing will happen.

```swift
rainer?.level = 87
// $R0: ()? = 87
```

## Control flow

[Control flow](https://en.wikipedia.org/wiki/Control_flow) encompasses the language constructs that allow to change the behavior of a program depending on its data.
Swift uses `if`, `switch` or `guard` to represent conditional statements, and `for-in`, while or `repeat-while` to represent loops.

### `if` statements

An `if` statement allows the program to check for a condition:

```swift
let pokemonLevel = 38

if pokemonLevel > 30 {
  print("the Pokemon won't obey")
} else {
  print("the Pokemon will obey")
}
```

Parentheses around the conditions are optional, and should not be used unless they make the code clearer.

> Unlike most languages of the C-family, Swift conditions must be a Boolean expression (i.e. of type `Bool`).
> As a result, `if pokemonLevel { ... }` is not be a valid expression in the above example, and the compiler would complain about it.

A special use of `if` is to both check if an optional variable is set (non-`nil`) and assign its value to another variable.
It is written as below:

```swift
let pokemonLevel: Int? = 38

if let level = pokemonLevel {
  print("the Pokemon level is \(level)")
} else {
  print("the Pokemon level is unknown")
}
```

Note that the above example is equivalent, but arguably clearer, than the following code.
You should use the previous variant as it is idiomatic of the Swift language.

```swift
if pokemonLevel != nil {
 print("the Pokemon level is \(pokemonLevel!)")
} else {
 print("the Pokemon level is unknown")
}
```

When testing an enumeration variable, it is possible to test if it is an instance of a specific `case`, and to extract the associated properties.
You should use this construct as it is idiomatic of the Swift language:

```swift
indirect enum SpeciesType {
  // ...
  case dual(primary: SpeciesType, secondary: SpeciesType)
}
let lotadType = SpeciesType.dual(primary: .water, secondary: .grass)
if case .dual(primary: let primary, secondary: let secondary) = lotadType {
  print("Lotad has two types: \(primary) and \(secondary)")
}
// "Lotad has two types: water and grass"
```

This feature is a simplified case of [pattern matching](https://en.wikipedia.org/wiki/Pattern_matching).
It is able to match a variety of patterns, that are presented later in this section, for instance:

```swift
let pokemon = (number: 001, name: "Bulbasaur")
if case let (number: x, name: y) = pokemon {
  print("\(y) has number \(x)")
}
if case 0 ... 10 = pokemon.number {
  print("the pokemon number is comprised between 0 and 10")
}
```

In addition to matching and extracting parts of a value, pattern matching can also apply some conditions.
Conditions are given separated by commas, that represent an “and”:

```swift
if case let (number: x, name: y) = pokemon, x > 50 {
  print("\(y) has a number greater than 50")
}
if case let x = pokemon.number, x > 50 {
  print("the pokemon number is greater than 50")
}
```

If both branches of an `if` construct are a single expression, then that construct can be used as an expression itself:

```swift
let name: String? = if Bool.random() { "Pikachu" } else { "Evee" }
```

### `switch` statements

A `switch` statement is a generalization of `if`.
It allows to select one among several conditions.
Contrary to the switch statement found in many languages, the `switch` in Swift performs pattern matching.

Pattern matching can, for instance, check that a number is within a range.
The `switch` statement works as follows: it tests each `case` in order, from the top to the bottom, and executes the first one that matches.
If no `case` matches the input, the `default` part is executed.

In the following example, note that cases are over range of integers.
The second `case 30 .. 100` overlaps with the first one, but with no problem as it is tested after:

```swift
let pokemonLevel = 31
switch pokemonLevel {
  case 50 ... 100:
    print("the Pokemon won't obey unless we have 4 badges")
  case 30 ... 100:
    print("the Pokemon won't obey unless we have 2 badges")
  default:
    print("the Pokemon will obey")
}
// "the Pokemon won't obey unless we have 2 badges"
```

A switch statement **must** cover all possible cases.
If Swift detects missing cases, it gives an error at compile-time.

```swift
let pokemonLevel = 31
switch pokemonLevel {
  case 50 ... 100:
    print("the Pokemon won't obey unless we have 4 badges")
  case 30 ... 100:
    print("the Pokemon won't obey unless we have 2 badges")
  case 0 ... 100:
    print("the Pokemon will obey")
}
// error: switch must be exhaustive, consider adding a default clause
```

The user should give a `default` clause if it is difficult to describe all cases.
For instance, as the `pokemonLevel` is a integer, the previous `switch` is complete with respect to the knowledge of the user (levels are between 0 and 100), but incomplete for the Swift compiler (integers are between larger bounds).
The user should add a `default` clause with an assertion:

```swift
let pokemonLevel = 31
switch pokemonLevel {
  case 50 ... 100:
    print("the Pokemon won't obey unless we have 4 badges")
  case 30 ... 100:
    print("the Pokemon won't obey unless we have 2 badges")
  case 0 ... 100:
    print("the Pokemon will obey")
  default:
    assert (false)
}
```

Unlike most C-family languages, Swift does not require a `break` after each case block.
Instead, only the code explicitly written in the matched case is executed, and the `switch` statement transfers control as soon as it's finished.
If multiple cases are handled by the same code, they are separated by a comma:

```swift
let pokemonLevel = 4
switch pokemonLevel {
  case 2, 4, 6:
    print("the Pokemon level is 2, 4 or 6")
  default:
    break
}
// "the Pokemon level is 2, 4 or 6"
```

This tutorial has already shown cases for ranges, enumerations and tuples.
All these [patterns](https://docs.swift.org/latest/documentation/the-swift-programming-language/patterns/) are available within switch.

```swift
indirect enum SpeciesType {
  // ...
  case dual(primary: SpeciesType, secondary: SpeciesType)
}

let lotadType = SpeciesType.dual(primary: .water, secondary: .grass)
switch lotadType {
  case .dual(primary: let primary, secondary: let secondary):
    print("the Pokemon has 2 types: \(primary) and \(secondary)")
  default:
    print("the Pokemon has 1 type: \(lotadType)")
}
// "the Pokemon has 2 types: water and grass"
```

### `for-in` loops

A `for-in` loop iterates over a sequence of elements:

```swift
var speciesNames = ["Bulbasaur", "Charmander", "Squirtle"]
for i in 0 ... 2 {
  print(speciesNames[i])
}
// Bulbasaur
// Charmander
// Squirtle
```

> Notice the `0 ... 2` in the above example.
> It creates a closed range from 0 to 2 included.
> Swift also has another range operator, `..<`, which creates half-open ranges.
> That is `0 ..< 2` creates a range from 0 to 2 but where 2 isn't included.

The `for-in` loop can iterate over anything that is a sequence.
For instance, a character string is also a sequence of `Character`:

```swift
for character in "ヒトカゲ".characters {
  print(character)
}
// ヒ
// ト
// カ
// ゲ
```

Arrays, sets and dictionaries are also sequences.
Hence they can be iterated over with a `for-in` loop.
Iteration over arrays and sets produces each element one after the other:

```swift
typealias Species = (number: Int, name: String)
let species: [Species] = [(001, "Bulbasaur"), (004, "Charmander"), (007, "Squirtle")]
for oneSpecies in species {
  print(oneSpecies.name)
}
// Bulbasaur
// Charmander
// Squirtle
```

Iteration over dictionaries is a bit different, as dictionaries are key-value pairs.
It thus produces pairs containing a key and its associated value (that is non-`nil`):

```swift
indirect enum SpeciesType { /* ... */ }

let speciesTypes = ["Bulbasaur": SpeciesType.grass, "Charmander": SpeciesType.fire]
for (speciesName, speciesType) in speciesTypes {
  print("species \(speciesName) has type \(speciesType)")
}
// species Charmander has type fire
// species Bulbasaur has type grass
```

The `for-in` construct supports pattern matching, just like `if`.
Users can use any pattern that has been presented previously:

```swift
let speciesTypes = ["Bulbasaur": SpeciesType.grass, "Charmander": SpeciesType.fire]
for case let (name, _) in speciesTypes where name.hasSuffix("aur") {
  print(name)
}
// Bulbasaur
```

### `while` and `repeat-while` loops

A `while` loop repeats a block of code as long as its condition holds.
Hence it is possible the loop will never execute any iteration:

```swift
let evolutions = ["Bulbasaur": "Ivysaur", "Ivysaur": "Venusaur"]
var pokemon = (level: 1, species: "Bulbasaur")
while evolutions[pokemon.species] != nil {
  pokemon = (level: pokemon.level, species: evolutions[pokemon.species]!)
}
// pokemon: (level: Int, species: String) = {
//   level = 1
//   species = "Venusaur"
// }
```

A `repeat-while` loop words similarly, but checks the condition after the block is executed, rather than before.
Hence the loop executes at least one iteration:

```swift
let evolutions = ["Bulbasaur": "Ivysaur", "Ivysaur": "Venusaur"]
var pokemon = (level: 1, species: "Bulbasaur")
repeat {
  pokemon = (level: pokemon.level, species: evolutions[pokemon.species]!)
} while evolutions[pokemon.species] != nil
// pokemon: (level: Int, species: String) = {
//   level = 1
//   species = "Venusaur"
// }
```

The keyword `continue` skips the remainder of loop body.
It is used to force passing to the next iteration.
In the case of a `for-in` or `while` loop, the program will pass to the next iteration and then evaluate the condition, whereas in the case of `repeat-while` loop, the program will evaluate the condition and then pass to the next iteration.

```swift
let evolutions = ["Bulbasaur": "Ivysaur", "Ivysaur": "Venusaur"]
var pokemon = (level: 1, species: "Bulbasaur")
repeat {
  if pokemon.species == "Ivysaur" {
    continue
  }
  pokemon = (level: pokemon.level, species: evolutions[pokemon.species]!)
} while evolutions[pokemon.species] != nil
// infinite loop, because the condition is always `true`
```

The keyword `break` exits the loop unconditionally.

```swift
let evolutions = ["Bulbasaur": "Ivysaur", "Ivysaur": "Venusaur"]
var pokemon = (level: 1, species: "Bulbasaur")
repeat {
  if pokemon.species == "Ivysaur" {
    break
  }
  pokemon = (level: pokemon.level, species: evolutions[pokemon.species]!)
} while evolutions[pokemon.species] != nil
// pokemon: (level: Int, species: String) = {
//   level = 1
//   species = "Ivysaur"
// }
```

### `guard` statements

A `guard` statement is similar to an `if` statement, but preferred in situations where some condition must hold for the program flow to continue:

```swift
struct Pokemon { /* ... */ }

let bulby = Pokemon(species: (number: 001, name: "Bulbasaur"), level: 8)

switch bulby {
  case let pokemon where pokemon.species.name == "Bulbasaur":
    guard pokemon.level >= 16 else {
      print("the Pokemon cannot evolve yet")
      break
    }
    print("the Pokemon can evolve")
  default:
    break
}
// the Pokemon cannot evolve yet
```

> Notice the use of the `break` keyword in the `else` clause of the guard.
> It is there is because `guard` should always transfer control if the condition doesn't hold, using `break`, `continue` or other kind of statements we'll see later.

A `guard` statement can always be replaced with an if statement.
`if` should be used when both the "then" and "else”"parts contain parts of the algorithm.
On the contrary, `guard` should be used when the algorithm only continues for the "then" part.

## Functions

[Functions](https://en.wikipedia.org/wiki/Function_(computer_programming)) are blocks of organized and reusable code that performs a single action, or group of related actions. As a program grows in complexity, they become mandatory.

This tutorial has already used some functions so far, like `print(:_)`, `type(of:)` or `Array.insert(_:at:)`.

### Function signatures

Functions are declared with the keyword `func`.
They are declared by a function name, parameter names and types, and a result type.
Each function contains a body that performs the effective computation:

```swift
func minInt(lhs: Int, rhs: Int) -> Int {
  return if rhs < lhs { rhs } else { lhs }
}
```

Like in mathematics, a function has a signature (i.e. a domain and a codomain).
In the above example, the signature of the function is `(Int, Int) -> Int`, meaning that it takes two `Int` parameters and returns one `Int` value.

When referring to a Swift functions in comments and documentation, the convention is to use its name, followed by the list of parameters separated by `:`.
For instance, the above function is written `minInt(lhs:rhs:)` in Swift documentation.
This convention is borrowed from Objective-C and can be observed through all official documentation.

> Note that this example just serves to illustrate the definition of functions.
> Swift already has a built-in `min(_:_:)` function which should always be preferred.

A function can be called by using its name, followed by the arguments to pass into its parameters.
Named parameters *must* be labeled in function calls, in the same order as they have been declared:

```swift
minInt(lhs: 1, rhs: 2)
// 1
```

Parameter names (aka argument labels) can prove very useful to distinguish overloaded functions, for code readability, or when the parameters are not completely obvious.
For instance, the character collection of a `String` has a method `split(whereSeparator:)` whose result is quite obvious, thanks to its labeled parameter.

It is possible to distinguish between the labels used for calling, and their name within the function body.
The calling name is put in the first place, and the body name in second:

```swift
func minInt(between lhs: Int, and rhs: Int) -> Int {
  return if rhs < lhs { rhs } else { lhs }
}
minInt(between: 1, and: 2)
// 1
```

When the name of the function is clear enough, it is possible to specify that the labels are not required in the function call using the `_` special name:

```swift
func minInt(_ lhs: Int, _ rhs: Int) -> Int {
  return if rhs < lhs { rhs } else { lhs }
}
minInt(1, 2)
// 1
```

Functions can return only one value, but this value can be a tuple.
For instance, the `minMaxInt` function takes 3 parameters and returns the minimum and maximum values:

```swift
func minMaxInt(_ first: Int, _ second: Int, _ third: Int) -> (minimum: Int, maximum: Int) {
    return (minimum: min(min(first, second), third), maximum: max(max(first, second), third))
}
minMaxInt(1, 2, 3)
// $R0: (minimum: Int, maximum: Int) = {
//   minimum = 1
//   maximum = 3
// }
```

A functions can also return nothing.
Such functions often have side effects, either on their parameters or on the execution environment, for instance by printing something or setting a value in an external database.
In this case, the return type of the function is `()` (read as “void”).
It is not required to be specified explicitly:

```swift
func greet(_ name: String) {
  print("Welcome \(name)!")
}
greet("Brock")
// Welcome Brock!
```

If a function returns a value, Swift expects this value to be used somewhere, otherwise the compiler emits a warning.
There are two ways to silent this warning.

If the result is expected to be used in most cases, it is the caller responsibility to discard it. The call must explicitly mark the result as unused by assigning it to the special _ = variable:

```swift
_ = minInt(1, 2)
```

If the result is only sometimes used, it is the function responsibility to discard it. The function must be decorated with `@discardableResult`:

```swift
@discardableResult
func printMin(between lhs: Int, and rhs: Int) -> Int {
  print(if rhs < lhs { rhs } else { lhs })
}
printMin(between: 1, and: 2)
```

In a function body, the `return` keyword in can be omitted when the body is made of a single expression:

```swift
func factorial(_ n: Int) -> Int {
  if n < 2 { 1 } else { n * factorial(n - 1) }
}
```

### Default arguments and overloading

Function can have default values for some of their parameters:

```swift
func greet(_ name: String, with message: String = "Welcome") {
  print("\(message) \(name)!")
}
greet("Brock", with: "Hello")
// Hello Brock!
greet("Brock")
// Welcome Brock!
```

Because of the default value on its message parameter, there are two ways to call the `greet(_:with:)` function, as illustrated in the example.
It is equivalent to writing two versions of this function:

- `greet(_:with:)` with signature `(String, String) -> ()`, and
- `greet(_:)` with signature `(String) -> ()`.

It is possible in Swift to create these two functions using [overloading](https://en.wikipedia.org/wiki/Function_overloading).
The same function name (greet) can be given to several functions, as long as their signatures differ. When calling the function name, the compiler chooses the function that matches the given parameters:

```swift
func greet(_ name: String, with message: String = "Welcome") {
  print("\(message) \(name)!")
}
func greet(_ name: String) {
  print("Welcome \(name)!")
}
greet("Brock", with: "Hello")
// Hello Brock!
greet("Brock")
// Welcome Brock!
```

Function overloading is generally a bad practice to define default arguments, but is a powerful feature because the signatures can be totally unrelated.
For instance, the following code allows to greet one person, or a group:

```swift
func greet(_ name: String) {
  print("Welcome \(name)!")
}
func greet(_ names: [String]) {
  greet(names.joined(separator: " and "))
}
greet("Brock")
// Welcome Brock!
greet(["Brock", "Misty"])
// "Welcome Brock and Misty!
```

Function overloading and default arguments can be combined together to create even more usable functions.
For instance, there are four possible calls of the `greet(_:)` function in the following example:

```swift
func greet(_ name: String, with message: String = "Welcome") {
  print("Welcome \(name)!")
}
func greet(_ names: [String], with message: String = "Welcome") {
  greet(names.joined(separator: " and "), with: message)
}
```

### Inout parameters

In the body of a function, the arguments are declared as `let` constants.
That means a function can't modify the value of its argument:

```swift
struct Pokemon { /* ... */ }
func swapPokemon(_ x: Pokemon, _ y: Pokemon) {
  let temporary = x
  x = y
  // Error: Cannot assign to value: 'x' is a 'let' constant
  y = temporary
  // Error: Cannot assign to value: 'y' is a 'let' constant
}
```

When writing code in functional style, the solution is to return the swapped elements, instead of modifying the parameters:

```swift
func swapPokemon(_ x: Pokemon, _ y: Pokemon) -> (Pokemon, Pokemon) {
  (y, x)
}
```

However, sometimes it is needed to update the function parameters.
Swift allows users to define mutable parameters by marking them as `inout`:

```swift
func swapPokemon(_ x: inout Pokemon, _ y: inout Pokemon) {
  let temporary = x
  x = y
  y = temporary
}
```

The caller of a function must be aware that the parameters will be modified.
Instead of only adding such information in the documentation, or in the function signature, Swift requires to explicitly prefix arguments given to `inout` parameters with `&`:

```swift
var x = Pokemon(species: (number: 134, name: "Vaporeon"), level: 58)
var y = Pokemon(species: (number: 135, name: "Jolteon"), level: 31)
swapPokemon(&x, &y)
(x, y)
// (Pokemon(species: (135, "Jolteon"), level: 31), Pokemon(species: (134, "Vaporeon"), level: 58))
```

> `&` is only a visual marker.
> It is not the the address-of operator as found in other languages like C, C++, or Rust.

Note that because the parameters are marked inout, the arguments must be variables.
It is not possible to call `swapPokemon(_:_:)` with a constant expression.

### Generic functions

In the above example, `swapPokemon(_:_:)` can only swap arguments of the `Pokemon` type.
It is impossible to call this function with anything else, even if the operations to perform are always the same.

```swift
indirect enum SpeciesType { /* ... */ }
var x = SpeciesType.grass
var y = SpeciesType.dual(primary: .water, secondary: .grass)
swapPokemon(&x, &y)
// Error: Cannot convert value of type 'SpeciesType' to expected argument type 'Pokemon'
```

Of course we could write another function `swapSpeciesType(_:_:)` that does the same thing for `SpeciesType` values.
But we also would have to write the same for `Species`, or simply `Int` and `String`.
[Generic programming](https://en.wikipedia.org/wiki/Generic_programming) allow us to write a function where one or several of its parameter or return types are abstracted:

```swift
func swapGeneric<T>(_ x: inout T, _ y: inout T) {
  let temporary = x
  x = y
  y = temporary
}

indirect enum SpeciesType { /* ... */ }
var a = SpeciesType.grass
var b = SpeciesType.dual(primary: .water, secondary: .grass)
swapGeneric(&a, &b)
```

In the above example, `T` acts as a placeholder for the type that will be used to specialize the function.
When calling `swapGeneric(&a, &b)`, the compiler infers that `T` should be replaced with `SpeciesType` in this function call, and it generates a version of `swapGeneric(_:_:)` typed `(inout SpeciesType, inout SpeciesType) -> ()`.

> Note that this example just serves to illustrate the definition of inout parameters.
> Swift already has a built-in `swap(_:_:)` generic function which should always be preferred.

### Error handling

Sometimes, returning an optional type to denote the success or failure of a function is not enough.
Indeed, it some situations it might be desirable for the caller to know exactly what is the cause the failure, so that it can take the appropriate action to recover from the error.
Swift handles this kind of errors via a mechanism of exception.

Errors can represented by types that conform to the `Error` protocol.
We'll see in what conforming to a protocol means later, but for the time being, we'll just consider this syntax:

```swift
enum PokemonError: Error {
  case outOfBoundsLevel
  case unknownSpeciesNumber(number: Int)
}
```

The above enumeration groups two custom errors, respectively representing an invalid Pokemon level, and an unknown species number.
When a program reaches a state that should be considered an error, it can throw an error type:

```swift
throw PokemonError.outOfBoundsLevel
```

Unlike in some other languages, Swift doesn't allow errors to propagate implicitly.
As a result, functions that may throw an error should be marked with the keyword `throws`:

```swift
struct Pokemon { /* ... */ }

func incrementingLevel(of pokemon: Pokemon) throws -> Pokemon {
  guard pokemon.level < 100 else {
    throw PokemonError.outOfBoundsLevel
  }

  return Pokemon(species: pokemon.species, level: pokemon.level + 1)
}
```

Incidentally, pieces of code that may throw an error must explicitly define how possible errors will be handled:

```swift
var rainer = Pokemon(species: (number: 134, name: "Vaporeon"), level: 100)

do {
  try rainer = incrementingLevel(of: rainer)
} catch PokemonError.outOfBoundsLevel {
  print("rainer already reached level 100")
} catch PokemonError.unknownSpeciesNumber(number: let number) {
  print("cannot raise the level of an unknown species: \(number)")
}
// Prints "rainer already reached level 100"
```

> Notice how a `do-catch` block can use pattern matching on the thrown error.

A `do-catch` block doesn't have to catch all possible errors.
Remaining cases will be propagated to the enclosing scope.
However, the latter will have to finish the job, unless it is a function marked with `throws`.

It is possible to use `try?` to convert a the result of a function marked with `throws` into an optional value.
If the function throws an error upon calling, the error will be handled as a `nil` return value:

```swift
var strongerRainer = try? incrementingLevel(of: rainer)
print(strongerRainer)
// Prints "nil"
```

Likewise, it is possible to use `try!` to immediately force-unwrap the result of a throwing function:

```swift
var strongerEevee = try! incrementingLevel(of: Pokemon(species: (number: 133, name: "Evee"), level: 12))
print(strongerRainer)
// Prints "nil"
```

If a function may throw an error, but requires some cleanup to be done before it transfers control, it is possible to mark a piece of code as deferred.
Doing so will ensure that the cleanup code is executed when the scope it is defined in is exited, either following a `return` statement, or because of a thrown error:

```swift
func readPokemonName(from filename: String) throws {
  let file = open(filename)
  defer {
    close(file)
  }

  // This statement may throw.
  return try readline(from: file)
}
```

> Note the the functions `open(_:)`, `close(_:)` and `readling(from:)` do not exist.
> Reading a file in Swift involves the Foundation library, and a slightly more complicated syntax that would hinder the clarity of that example.

## Properties and methods

We've seen in the beginning of this tutorial that we can associate properties with structs.
However, this that is not the full story, as Swift properties can be more than mere constants or variables.

### Stored and computed properties

Stored properties are stored as part of their struct.
We've seen them in action in the previous examples:

```swift
typealias Species = (number: Int, name: String)

struct Pokemon {
  let species: Species
  var level: Int
}
```

The `Pokemon` struct is declared with two stored properties. One is a constant, the other is a variable.

Computed properties aren't stored in their struct.
Instead, they are computed every time they are `get` or `set`:

```swift
struct Pokemon {
  let species: Species
  var level: Int

  var stepsWalkedWithTrainer: Int
  var kmWalkedWithTrainer: Double {
    get {
      return Double(self.stepsWalkedWithTrainer) * 0.00076
    }

    set {
      self.stepsWalkedWithTrainer = Int(newValue * 1/0.00076)
    }
  }
}

var bulby = Pokemon(
  species: (001, "Bulbasaur"),
  level: 1,
  stepsWalkedWithTrainer: 600)

print(bulby.kmWalkedWithTrainer)
// Prints "0.456"
bulby.kmWalkedWithTrainer = 2.1
print(bulby.stepsWalkedWithTrainer)
// Prints "2763"
```

> In the above example, `self` is a constant that contains the value of the Pokemon instance.
> This variable is available to the getter and setter because they act like a method, which will discuss further below.

A stored property `stepsWalkedWithTrainer` has been added, which keeps track of the number of steps a trainer walked with his/her Pokemon.
A computed property `kmWalkedWithTrainer` computes the number of kilometers it represents when accessed, and converts back into steps when set.

Notice that the setter automatically receives an argument `newValue`.
This constant contains the new value to be assigned to the property.

If it shouldn't be (our wouldn't make sense to) set, it is possible to omit the `get` and `set` keywords to only write the code of the getter:

```swift
struct Pokemon {
  /* ... */

  var hasReachedMaxLevel: Bool {
    return self.level == 100
  }
}
```

In the above example, a computed property `hasReachedMaxLevel` returns whether the Pokemon reached is maximum level.
The property is read-only, as it wouldn't make any sense to set it.
Indeed, what level value would be appropriate?

While enumerations can't have stored properties, they can define computed ones:

```swift
indirect enum SpeciesType {
  case grass, fire, water
  case dual(primary: SpeciesType, secondary: SpeciesType)

  var isDual: Bool {
    // Unfortunately, Swift doesn't have a syntax to return the result of this condition.
    if case .dual(primary: _, secondary: _) = self {
      return true
    }
    return false
  }
}

let lotadType = SpeciesType.dual(primary: .water, secondary: .grass)
print(lotadType.isDual)
// Prints "true"
```

### Lazy properties

Lazy (stored) properties are similar to read-only computed properties, but differ in the fact that they're computed only once, and only if explicitly accessed after initialization.
Hence, they have two use cases:

- When its value depends on something that can't be even after initialization.
- When computing its value it is expensive.

The following example illustrates the second use-case, with the assumption that the function `loadPokedexEntry(of:)` actually requires a long and expensive call to an external service.

```swift
func loadPokedexEntry(of pokemon: Pokemon) -> String {
  return "Bulbasaur, the Seed Pokemon."
}

struct Pokemon {
  /* ... */

  lazy var pokedexEntry = {
    print("loading the Pokedex entry ...")
    return loadPokedexEntry(of: self)
  }()
}

var bulby = Pokemon(
  species: (001, "Bulbasaur"),
  level: 1,
  stepsWalkedWithTrainer: 600,
  pokedexEntry: nil)

print(bulby.pokedexEntry)
// Prints "loading the Pokedex entry ..."
// Prints "the Seed Pokemon"
print(bulby.pokedexEntry)
// Prints "the Seed Pokemon"
```

Notice that another parameter appeared in the memberwise initializer.
That is because `pokedexEntry` is a property, and like all properties it should be initialized.
If it hadn't been initialized with `nil`, the close associated with the lazy property would never have been called.
In the above example, it is called only once, when we first access the `pokedexEntry` property.

Note that a lazy property can't be declared a constant.
The reason is that constant properties must always have a value before initialization completes.
Besides, a lazy property is mutating, meaning that it changes the struct it is defined in.
Indeed, it is able to modify the value it was initialized with.

### Static properties

All the properties we've seen above have been defined for the instances of a type, meaning that each instance of the type gets its own property values.
Swift also allows to define properties on the type itself.
There will be only one copy of that properties, no matter how many instances get created.

```swift
struct Pokemon {
  /* ... */

  static let maxLevel: Int = 100
}

print(Pokemon.maxLevel)
// Prints: 100
```

Note that all type properties **must** have a value.
Unlike type instances, types are initialized when the program starts.
As a result, they require all their properties to be properly initialized.

### Methods

A method is a function that is associated with a particular instance of a type.
They can be seen as a function (like the ones we have discussed earlier) that and assigns the instance to which it is associated with a special variable `self`.
Methods have the exact same syntax as functions:

```swift
struct Trainer {
  let name: String
  var friends: [Trainer]

  func isFriends(with anotherTrainer: Trainer) -> Bool {
    for f in self.friends where f.name == anotherTrainer.name { return true }
    return false
  }
}

var ash = Trainer(name: "Ash", friends: [])
var brock = Trainer(name: "Brock", friends: [])

ash.friends.append(brock)
print(ash.isFriends(with: brock))
// Prints "true"
```

> It is not mandatory to prepend a type'' own property with `self` inside a method.
> Hence, we could have written only `friends` rather than `self.friends` in the body of `isFriend(with:)`, since `friends` is a property of `Trainer`.

Friendship is *usually* commutative.
In the above example however, stating that `Brock` is a friend of `Ash` doesn't make `Ash` a friend of Brock.
We can fix this problem by modifying our method so that it updates the relation.
However, methods cannot modify `self` by default.
To tell Swift otherwise, we must declare that the method is `mutating`.
Also, remember that only `inout` parameters can be modified.

```swift
struct Trainer {
  /* ... */

  mutating func makeFriends(with anotherTrainer: inout Trainer) {
    self.friends.append(anotherTrainer)
    anotherTrainer.friends.append(self)
  }
}
```

Incidentally, it is possible to assign `self` to a complete new instance in a mutating struct method:

```swift
struct Pokemon {
  let species: Species
  var level: Int

  mutating func evolve() {
    self = Pokemon(species: (002, "Ivysaur"), level: self.level)
  }
}

var bulby = Pokemon(species: (001, "Bulbasaur"), level: 16)
bulby.evolve()
print(bulby)
// Prints "Pokemon(species: (2, "Ivysaur"), level: 16)"
```

Had `evolve()` been a non-mutating method that returns a new instance of Pokemon, the above code would be equivalent to:

```swift
struct Pokemon {
  let species: Species
  var level: Int

  func evolve() -> Pokemon {
    Pokemon(species: (002, "Ivysaur"), level: self.level)
  }
}

var bulby = Pokemon(species: (001, "Bulbasaur"), level: 16)
bulby = bulby.evolve()
print(bulby)
// Prints "Pokemon(species: (2, "Ivysaur"), level: 16)"
```

Enumeration can also declare methods:

```swift
indirect enum SpeciesType {
  case grass, fire, water
  case dual(primary: SpeciesType, secondary: SpeciesType)

  func combine(with anotherType: SpeciesType) -> SpeciesType {
    return .dual(primary: self, secondary: anotherType)
  }
}

var lotadType = SpeciesType.water.combine(with: .grass)
```

Like functions, methods can be defined with default arguments and/or be overloaded:

```swift
struct Pokemon {
  let species: Species
  var level: Int

  mutating func levelUp(by levels: Int = 1) {
    self.level += levels
  }
}
```

Finally, similarly as type properties, Swift allows to define static methods on structs and enumerations:

struct Pokemon {
  /* ... */

  static func createFromSpecies(_ species: Species) -> Pokemon {
    Pokemon(species: species, level: 1)
  }
}

let bulby = Pokemon.createFromSpecies((001, "Bulbasaur"))

### Subscripts

We've already used subscripts with arrays and dictionaries, to get an indexed value:

```swift
let letters = ["A", "s", "h"]
print(letters[1])
// Prints "h"
```

Custom subscripts can be defined on structs and enumerations.
For instance, here is a (rather poor) alternative implementation of a dictionary `[Int: String]`:

```swift
struct InefficientDictionary {
  var storage: [(Int, String)]
  subscript(key: Int) -> String? {
    get {
      for (k, v) in storage where k == key { return value }
      return nil
    }
    set {
      for i in storage.indices() where storage[i].0 == key {
        if let v = newValue { storage[i].1 = v } else { storage.remove(at: i) }
        return
      }
    }
  }
}

var pokedex = InefficientDictionary(storage: [])
pokedex[001] = "Bulbasaur"
print(pokedex[001]!)
// Prints "Bulbasaur"
```

Similarly to computed properties, the `get` keyword can be dropped if the subscript should only be used to read a value.

Most of the time, subscripts accept only one argument but several can be defined as well.
For instance, it is a common practice to represent a matrix n × m as a 1-dimensional array:

```swift
struct Matrix {
  var grid: [Int]

  subscript(row: Int, column: Int) -> Int {
    grid[row * column + column]
  }
}

let matrix = Matrix(grid: [0, 1, 2, 3])
print(matrix[1, 1])
// Prints "3"
```

### Initializers

Swifts statically enforces that any variable is initialized before it is used.
We've been mostly using default initializers so far, but it is also possible to define custom initializers for stucts and even enumerations.

As we've seen earlier, structs receive a memberwise initializer if none is explicitly defined:

```swift
typealias Species = (number: Int, name: String)

struct Pokemon {
  let species: Species
  var level: Int
}

let sparky = Pokemon(species: (135, "Jolteon"), level: 31)
```

Another way to initialize a struct is to provide default values for its properties.
In that case, the struct receives a default initializer with no parameter:

```swift
struct Pokemon {
  let species: Species = (135, "Jolteon")
  var level = 1
}

let sparky = Pokemon()
```

> Note that by providing a default value for `Pokemon.species`, we actually disallow any Pokemon to have another species, as the constant won't never be mutable for any instance of Pokemon.

For a finer control on how a struct gets initialized, Swift also allows to define custom initializers.
They have the same syntax as methods, except that they are defined with the keyword `init` and cannot return anything.

```swift
struct Pokemon {
  let species: Species
  var level: Int

  init(species: Species, level: Int = 1) {
    self.species = species
    self.level = level
  }
}
```

> Note that as soon as you define a custom initializer, Swift doesn't provide you with neither default not memberwise initializer anymore.

Initializers can have any parameter and perform any kind of operation.
The only requirement is that they initialize all properties before they transfer control:

```swift
struct Pokemon {
  let species: Species
  var level: Int

  init(speciesNumber: Int, speciesName: String, level: Int = 1) {
    self.species = (number: speciesNumber, name: speciesName)
    self.level = level
  }
}

let sparky = Pokemon(speciesNumber: 135, speciesName: "Jolteon", level: 31)
```

As one would guess, self is mutating inside an initializer (as otherwise the initializer wouldn't be able to initialize its values).
Nevertheless, a struct initializer can't read its properties before they are initialized:

```swift
struct Pokemon {
  let species: Species
  var level: Int

  init(speciesNumber: Int, speciesName: String, level: Int = 1) {
    self.species = (number: speciesNumber, name: speciesName)
    self.level = self.level + 1
    // Error: 'self' used before all stored properties are initialized
    self.level = level
  }
}
```

Initializers can also delegate part of all their work to other initializers:

```swift
struct Pokemon {
  let species: Species
  var level: Int

  init(species: Species, level: Int) {
    self.species = species
    self.level = level
  }

  init(speciesNumber: Int, speciesName: String, level: Int = 1) {
    self.init(species: (speciesNumber, speciesName), level)
  }
}

let sparky = Pokemon(speciesNumber: 135, speciesName: "Jolteon", level: 31)
```

> In the above example, notice that the initializer of `Pokemon` has been overloaded.
> With the addition of the default parameter on the second initializer, it is now possible to
> initialize `Pokemon` with `init(species:level:)`, `init(speciesNumber:speciesName:)` and `init(speciesNumber:speciesName:level:)`.

Although less common, enumerations can also define
initializers. Since enumerations can't have stored properties, the only job of its inits initializer(s) is to provide a value for `self`:

```swift
indirect enum SpeciesType {
  case grass, fire, water
  case dual(primary: SpeciesType, secondary: SpeciesType)
  case unknown

  init(fromSpecies species: Species) {
    switch species.name {
    case "Bulbasaur":
      self = .grass
    case "Charmander":
      self = .fire
    default:
      self = .unknown
    }
  }
}

let bulbasaurType = SpeciesType(fromSpecies: (001, "Bulbasaur"))
print(bulbasaurType)
// Prints "grass"
```

> Notice that we added a case `unknown` to the enumeration, to handle the case we failed to match the name of the species.

### Failable initializers

It sometimes happens that the success or failure of a struct or enumeration initialization cannot be decided statically.
For instance, a struct may read its properties from an external source (like a database or an archive), from which the data may have been corrupted.
Swift allows to declare initializers as failable to handle this kind of situations.
A failable initializer can either successfully initialize its type, or "return" `nil` if the initialization failed.
Failable initializers are declared by appending `?` after the `init` keyword:

```swift
let speciesList = [(001, "Bulbasaur"), (004, "Charmander"), (007, "Squirtle")]

struct Pokemon {
  let species: Species
  var level: Int

  init?(speciesNumber: Int, level: Int = 1) {
    guard let species = speciesList.first(
      where: { number, _ in number == speciesNumber }) else {
      return nil
    }

    self.species = species
    self.level = level
  }
}
```

In the above example, it is possible to instantiate `Pokemon` with a species number.
However, there's no way to ensure that the given species number is known at compile time.
Hence, the constructor is marked failable, and a guard makes sure the species number is valid before initializing the object.

When instantiating a type with a failable initializer, the returned object is always an optional of that type:

```swift
let bulby = Pokemon(speciesNumber: 001)
print(type(of: bulby))
// Prints "Optional<Pokemon>"
```

Enumerations can also declare a failable initializer.
That is particularly useful when there's no valid case that matches the initializer arguments.
For instance, our earlier example of initializer for `SpeciesType` could be rewritten without the need of the additional `unknown` case:

```swift
indirect enum SpeciesType {
  case grass, fire, water
  case dual(primary: SpeciesType, secondary: SpeciesType)

  init(fromSpecies species: Species) {
    switch species.name {
    case "Bulbasaur":
      self = .grass
    case "Charmander":
      self = .fire
    default:
      return nil
    }
  }

}
```

## Protocols and extensions

Protocols represent a set of requirements that a type accepts to conform to.
Although some major differences can be observed,
they can be assimilated to what other languages (like Java) call interfaces.

### Protocol requirements

A protocol is declared with the keyword `protocol`:

```swift
protocol Technique {
  // The protocol requirements go here.
}
```

Custom types can then be declared to *conform* to one or more protocols (i.e. implement their set of requirements).
Structs and enumerations can conform to a protocol:

```swift
struct Ember: Technique {
  // The implementations of the protocol requirements go here.
}
```

A protocol can be declared conforming to one or more protocols as well:

```swift
protocol Technique: AnotherProtocol {
  // Requirements specific to `Technique` go here.
}
```

A protocol can require its conforming types to implement a particular property, with a particular name and type.
It can also precise if that property should be *at least* read-only or also modifiable.

```swift
protocol Technique {
  var name: String { get }
  var usedPowerPoints: Int { get set }
}

struct Ember: Technique {
  let name: String
  var usedPowerPoints: Int
}
```

Note that the property `usedPowerPoints` has to be declared a variable in `Ember`, because the protocol `Technique` states it should be modifiable.
The property `name` on the other hand may be declared as a variable rather than a constant, because the protocol only states that is should be *at least* read-only.

Property conformance can also be achieved with computed properties:

```swift
enum Language {
  case english, french, german, japanese
}

let displayLanguage = Language.japanese

struct Ember: Technique {
  var name: Int {
    switch displayLanguage {
    case .japanese:
      return "ひのこ"
    case .french:
      return "Flammèche"
    default:
      return "Ember"
    }
  }

  var usedPowerPoints: Int
}
```

Properties can also be required to be implemented at the type level (i.e. statically):

```swift
protocol Technique {
  /* ... */

  static var maxPowerPoints: Int { get }
}

struct Ember: Technique {
  /* ... */

  static let maxPowerPoints: Int =　25
}
```

> Note that the type property `maxPowerPoints` is defined for the `Ember` type only.
> Any other protocol that conforms to `Technique` will have to define its own `maxPowerPoints` property, and it will be unrelated from that of `Ember`.

A protocol can require its conforming types to implement a particular method, with a particular name and signature:

```swift
typealias Species = (number: Int, name: String)

struct Pokemon {
  let species: Species
  var level: Int
  var lostHealthPoints: Int
}

protocol Technique {
  /* ... */

  func perform(on defender: Pokemon) -> Pokemon
}

struct Ember {
  /* ... */

  func perform(on defender: Pokemon) -> Pokemon {
    return Pokemon(
      species: defender.species,
      level: defender.level,
      lostHealthPoints: defender.lostHealthPoints + 12)
  }
}
```

If a method should be able to mutate its type, a protocol can mark it `mutating`.
If it does, the mutable can be mutable or not.
If it doesn't, the method **can't** be mutating:

```swift
protocol Technique {
  /* ... */

  mutating func perform(on defender: Pokemon) -> Pokemon
}

struct Ember {
  /* ... */

  mutating func perform(on defender: Pokemon) -> Pokemon {
    self.usedPowerPoints += 1
    return Pokemon(
      species: defender.species,
      level: defender.level,
      lostHealthPoints: defender.lostHealthPoints + 12)
  }
}
```

Finally, a protocol can require its conforming types to implement a particular initializer:

```swift
protocol Technique {
  /* ... */

  init(usedPowerPoints: Int)
}

struct Ember {
  /* ... */

  init(usedPowerPoints: Int = 0) {
    self.usedPowerPoints = usedPowerPoints
  }
}
```

> Note that protocols don't allow to define default arguments in intializer (or method) requirements.
> The conforming types however are free to do so.

## Protocols as types

Even if protocols don't represent actual objects (or instances of), they can be used as a type in your code.
The idea is similar as the use of a base class to denote any instance of its derived classes in other languages.

```swift
struct Ember: Technique { /* ... */ }
struct Surf: Technique { /* ... */}

let techniques: [any Technique] = [Ember(), Surf()]
print(techniques)
// Prints "[Ember(usedPowerPoints: 0), Surf(name: "Surf", usedPowerPoints: 0)]"
```

> Note that we are forced to explicit type the `techniques` array, because Swift's type inference doesn't search for matching protocols, only for concrete types.
> In fact, doing so could lead to ambiguities for types that would conform to multiple protocols.
> For instance, what should be the type of `array` in the following example?
>
> ```swift
> protocol P1 {}
> protocol P2 {}
>
> struct S1: P1, P2 {}
> struct S2: P1, P2 {}
>
> let array = [S1(), S2()]
> ```

## Self Requirements

One of the features that distinguish a protocol the most from what is generally understood as interfaces is their ability to refer to the type that conforms to it.
This is called a *self requirement*:

```swift
protocol Technique {
  /* ... */

  static func == (lhs: Self, rhs: Self) -> Bool
}

struct Ember: Technique {
  /* ... */

  static func == (lhs: Ember, rhs: Ember) -> Bool {
    return lhs.usedPowerPoints == rhs.usedPowerPoints
  }
}
```

In the protocol definition, `Self` acts as a placeholder for the type that will conform to its requirements.
As a result, the implementation of the `==` operator in `Ember` is typed `(Ember, Ember) -> Bool`, and not `(Technique, Technique) -> Bool`.
Self requirements enable a finer grained specification of the protocol.

Actually, Swift already has an `Equatable` built-in protocol that acts exactly as the self requirement in the above example.
All built-in types that are equatable respect this protocol, which allows to write things like `8 == 8`.
Remembering that protocols can be declared conforming to other protocols,
The above example could be rewritten as the following:

```swift
// already defined in Swift:
// protocol Equatable {
//   static func == (lhs: Self, rhs: Self) -> Bool
// }

protocol Technique: Equatable { /* ... */ }
struct Ember: Technique { /* ... */ }
```

## Associated Types

A protocol can also declares placeholders for the types it should be associated with.
That is useful when the conforming type should have some kind of relationship with another type:

```swift
protocol Stack {
  associatedtype Element

  var head: Element? { get }

  init(_ initialValue: [Element])

  func pushing(_ element: Element) -> Self
  func popped() -> Self
}

struct ArrayBackedStack: Stack {
  typealias Element = Int

  var storage: [Element]

  var head: Element? {
    self.storage.last
  }

  init(_ initialValue: [Element] = []) {
    self.storage = initialValue
  }

  func pushing(_ element: Element) -> ArrayBackedStack {
    ArrayBackedStack(self.storage + [element])
  }

  func popped() -> ArrayBackedStack {
    ArrayBackedStack(Array(self.storage.dropLast()))
  }
}

var stack = ArrayBackedStack([8, 3])
print(stack.popped().head!)
// Prints "8"
```

The `Stack` protocol defines an associated type `Element`, which acts as a placeholder for the properties and methods requirements.
Conforming types can then specify which other type they'd like to use as the association.
In the above example, `ArrayBackedStack` chooses `Int` as its associated type, by declaring a type alias.

This mechanism allows a certain degree of genericity.
A protocol can design the requirements for an unlimited number of conforming types that would have the same form.
Note also that as many associated types as needed can be declared.
Later in this chapter, we'll see how we can go even further into that direction.

## Extensions

Extensions allows to add functionalities (or conforming protocols) to existing types.
As they are declared *outside* a type declaration, they don't require to know anything more than the public interface of the type they extend.
Extensions can:

- add computed instance and type properties;
- add instance and type methods;
- provide new initializers; and
- make existing types conform to a protocol.

Extensions are declared with the keyword `extension`, followed by the name of the type they extend:

```swift
typealias Species = (number: Int, name: String)

struct Pokemon { /* ... */ }

extension Pokemon {
  var description: String {
    "a \(self.species.name) at level \(self.level)"
  }
}

let sparky = Pokemon(species: (135, "Jolteon"), level: 31)
print(sparky.description)
// Prints "a Jolteon at level 31"
```

> Note that extensions **cannot** add stored instance properties, or add property observers to existing properties.
> Doing that would change the size of the extended type's instances, which would introduce a host of issues regarding initialization, serialization or usability in general.
>
> Static properties are not concerned by this limitation, as they do not change the size of the type's instances.
> They are stored ad-hoc fashion.

Extensions can also be defined on a protocol.
Doing so extends all types that conform to the protocol:

```swift
extension Technique {
  var remainingPowerPoints: Int {
    Self.maxPowerPoints - self.usedPowerPoints
  }
}

let ember = Ember(usedPowerPoints: 7)
print(ember.remainingPowerPoints)
// Print "18"
```

> Note that `Self` (with a capital letter) corresponds to the type of `self`.
> In other words, `Self = type(of: self)`.

Protocol extensions can be used to give a default implementation to a protocol method requirement:

```swift
extension Technique {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.usedPowerPoints == rhs.usedPowerPoints
  }
}

struct Ember: Technique {
  /* ... */

  // Use the default implementation defined in the extension if not defined.
  // static func == (lhs: Ember, rhs: Ember) -> Bool {
  //   return lhs.usedPowerPoints == rhs.usedPowerPoints
  // }
}
```

Extensions only need to access the public interface of the type they extend.
As a result, they can be defined on types that otherwise couldn't be modified:

```swift
extension Int {
  subscript(digit n: Int) -> Int {
    if n == 0 { self % 10 } else { (self / 10)[digit: n - 1] }
  }
}

6485[digit: 1]
// Prints "8"
```

## Protocols and Generics

We have discussed generic functions earlier.
Swift also allows to declare generic types, for which generic parameters apply to the whole type.
Remembering our example of stack that illustrated associated types, earlier in this chapter, here is another way to implement a generic stack.

```swift
struct ArrayBackedStack<T> {
  var storage: [T]

  var head: T? {
    return self.storage.last
  }

  init(_ initialValue: [T] = []) {
    self.storage = initialValue
  }

  func pushing(_ element: T) -> ArrayBackedStack {
    return ArrayBackedStack(self.storage + [element])
  }

  func popped() -> ArrayBackedStack {
    return ArrayBackedStack(Array(self.storage.dropLast()))
  }
}

var stack = ArrayBackedStack([8, 3])
print(stack.popped().head!)
// Prints "8"
```

In the first example, initializing a stack with `Double` elements would have required to define a new kind of stack, whose associated type would have been set to `Double`.
Now, it suffices to specialize `ArrayBackedStack` for any other type:

```swift
var stackOfDouble = ArrayBackedStack([8.3, 3.8])
print(stackOfDouble.popped().head!)
// Prints "8.3"
```

But we lost protocol conformance.
In the other previous case, `ArrayBackedStack` was conforming to `Stack`.
While this had the advantage of better describing the role of the type,
it also meant that `ArrayBackedStack` would have benefitted from all extensions that could be made to `Stack`.
Thankfully, Swift allows for generic types to work with protocols as well:

```swift
struct ArrayBackedStack<T>: Stack { /* ... */ }

extension Stack {
  var elements: [Element] {
    if self.head == nil {
      return []
    }
    return [self.head!] + self.popped().elements
  }
}

print(ArrayBackedStack(["chu!", "Pika"]).elements.joined())
// Prints "Pikachu!"
```

Once again, `ArrayBackedStack` conforms to `Stack`, and hence benefits from its extensions.
With the help of function signatures, the compiler was even able to infer that the associated type `Element` had to be mapped onto its the parameter `T`.
Hence, it wasn't required to add `typealias Element = T` in the type definition.

In all above examples, the compiler also inferred the type of the stacks,
because of the type of the array they was given as argument.
However, it is possible (and sometimes necessary) to declare explicitly how a generic type should be specialized:

```swift
let stackOfInts: ArrayBackedStack<Int>
```

It is possible to add type constraints on the generic parameters (note that this is also true for generic function):

```swift
struct ArrayBackedStack<T: Equatable> { /* ... */ }

let stackOfInts: ArrayBackedStack<Int>
let stackOfSpeciesTypes: ArrayBackedStack<SpeciesType>
// Error: Type 'SpeciesType' does not conform to protocol 'Equatable'
```

Type constraints can even be much more complex.
For instance, the following function accept any pair of type conforming to `Stack`, as long as are containers for the same elements, and that the type of these elements is equatable:

```swift
func == <S1: Stack, S2: Stack>(lhs: S1, rhs: S2) -> Bool
    where S1.Element == S2.Element, S1.Element: Equatable {
  guard let leftHead = lhs.head else {
    return rhs.head == nil
  }
  guard let rightHead = rhs.head, leftHead == rightHead else {
    return false
  }
  return lhs.popped() == rhs.popped()
}

print(ArrayBackedStack([1, 2]) == ArrayBackedStack([1, 2]))
// Prints "true"
```

## Pointers

Desipte its high-level features, Swift also lets users perform low-level operations very close to the hardware to implement high-performance algorithms and data structures.
Some of this support includes pointers.

A pointer is simply the address of some storage that may hold a value in memory:

```swift
var x = 123
withUnsafePointer(to: &x) { (p) -> Void in
  print(p)
}
// Prints 0x00000001000ac040 (or some other address)
```

> The curly braces after the call to `withUnsafePointer` denote a closure.
> Here, the closure is a function with the signature `(UnsafePointer<Int>) -> Void`, meaning that it accepts a pointer to an integer and returns nothing.
> The underlying mechanism is quite involved but not very important in the context of this tutorial.

Pointers are said to be unsafe because using them incorrectly may trigger undefined behavior.
For this reason, pointers should be used as sparingly and code using them should require extra scrutiny.
One golden rule is that the value of a pointer should never be used after the storage to which it refers has been deallocated.
The following precautions can be applied to satisfy this rule:

- Do not let pointers escape from closures passed to `withUnsafeXXX`.
- Do not store pointers in data structures that escape closures passed to `withUnsafeXXX`.

We can access the value referred to by a pointer by dereferencing it.

```swift
var x = 123
withUnsafeMutablePointer(to: &x) { (p) -> Void in
  p.pointee += 321
}
print(x)
// Prints 444
```

Languages Java, Scala, and Python use a boxed representation, meaning that the fields of a class may be allocated in completely different parts of the memory.
In contrast, stored properties are tightly laid out inline in Swift.
As a result, a pointer to the start of a struct or tuple also points to all the properties of that struct or tuple.

```swift
var pair = (true, false)
withUnsafeMutablePointer(to: &pair) { (p) in
  let q = UnsafeMutableRawPointer(p)
  let r = q.advanced(by: 1)
  r.assumingMemoryBound(to: Bool.self).pointee = true
}
print(pair)
// Prints (true, true)
```

This piece of code is rather complex so let us go step by step.
First, we called `withUnsafeMutablePointer(to:_:)` to obtain a pointer containing the address of `pair`.
Next, we turned that pointer into a "raw" pointer.
That is, we asked the compiler to forget about the type of the referred memory, so that we could look at the raw bytes of the pair.
Next, we advanced the pointer `r` by one byte, making it point to the second element of the pair.
Finally, we asked the compiler to trust that we are indeed pointing to a Boolean value and we wrote something at that address.

> In a future lecture we will discuss how to compute the sizes of a type reliably.
> For now, assuming a 64-bit architecture, we can assume that the size of `Bool` is 1 byte and that the size of `Int` is 8 bytes.

We can also look at the memory of an array.

```swift
var xs = [1, 2, 3]
xs.withUnsafeBufferPointer { (p) in
  print(p.baseAddress!, p.count)
}
// Prints 0x00000001000ac040 (or some other address) and then 3 (or some greater number)
```

Here, `p` is an `UnsafeBufferPointer<Int>` rather than a simple `UnsafeBuffer<Int>`.
The difference is that the former also specifies the number of instances of `Int` that can be stored in the referred buffer.
We read that capacity using the `count` property.
Any pointer resulting from the base address advanced by `i * s` where `s` is the size of `Int` and `i` is less than `count` is referring to allocated memory.
However, just because the memory is allocated does not mean there is a value there!

```swift
withUnsafeTemporaryAllocation(of: Int.self, capacity: 16) { (p) in
  let q = UnsafeMutableRawPointer(p.baseAddress!)
  let r = q.advanced(by: 24)
  print(r.assumingMemoryBound(to: Int.self).pointee)
}
// Prints some value
```

Here, we used `withUnsafeTemporaryAllocation(of:capacity:_:)` to create a temporary buffer capable of storing at 16 integers.
Then, we use the same approach as before to access the third position of that buffer.
We got a pointer to valid memory but this memory was never initialized, meaning that reading it gave us an arbitrary value.
This program is an example of undefined behavior.
There is no way to predict the outcome of the program that triggers undefined behavior.
In fact, such a program could do anything, including summoning demons from the depths of your nostrils!
