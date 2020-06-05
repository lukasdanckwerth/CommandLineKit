# CommandLineKit  [![Build Status](https://travis-ci.com/lukasdanckwerth/CommandLineKit.svg?branch=master)](https://travis-ci.com/lukasdanckwerth/CommandLineKit)

![Icon](.documentation/icon.low.png "Icon")

> CommandLineKit is a micro framework enabling you to build clean, short and safe command line tools written in Swift.

- [Requirements](#requirements)
- [Usage](#usage)
    - [Options and Arguments](#`option`s-and-`argument`s)
    - [Multivalued Arguments](#multivalued-`Arguments`)
    - [Custom validation of Options and Arguments](#custom-validation-of-options-and-arguments)
    - [Required Arguments](#required-arguments)
    - [Options with required arguments](#options-with-required-arguments)
    - [Default values for Arguments](#Default-values-for-Arguments)
    - [Enum options](#Enum-options)
    - [Enum Arguments](#Enum-Arguments)
    - [Parsing command line arguments](#Parsing-command-line-arguments)
- [Features](#Features)
    - [Options Catalog](#options-catalog)
    - [Arguments Catalog](#arguments-catalog)
    - [Custom Options and Arguments](#custom-options-and-arguments)
    - [Configuration](#configuration)
    - [Manual Printer](#manual-printer)
- [Author](#author)
- [Inspired by](#inspired-by)
- [Licence](#licence)

## Requirements
- Xcode 9.2+
- Swift 4+

## Usage

```swift
let option = Option(name: "option", help: "Does some fancy stuff.")
let stringOption = StringOption(name: "stringOption", help: "Takes a String value.")
let numberOption = NumberOption(name: "numberOption", help: "Takes an Int value.")

CommandLineInterface.parseOrExit() // Would `exit(EXIT_FAILURE)` if parsing throws an exception ...

CommandLineInterface.option {

case option:
    print("Selected \(option)")
case stringOption:
    let stringValue = stringOption.value
    print("Selected string option with value \(stringValue)")
case numberOption:
    let intValue = numberOption.value
    print("Selected number option with value \(intValue)")
default:
    print("No option selected.")
}

```

> Have you noticed that it is not neccessary to add the options to the `CommandLineInterface`? By default new instanciated `Options` and `Arguments` are added to the default `CommandLineInterface` instance stored in the static `default` property of the `CommandLineInterface` class. 

### Options and Arguments

`Option`s are meant for specifying a task to do by the command line tool whereas `Argument`s specify the behaviour when executing the task. When parsing a `CommandLineInterface` expects the specification of exactly one `Option`. The naming of an `Argument` is not required for running a command line tool.

#### Multivalued Arguments

```swift
let numberCollectionArgument = NumberCollectionArgument(longFlag: "numberCollection", shortFlag: "nc")
let stringCollectionArgument = StringCollectionArgument(longFlag: "stringCollection", shortFlag: "sc")
...
// $ example --numberCollection 9 8 7 1 --stringCollection Hello World
...
print(numberCollectionArgument.values)   // Prints [9, 8, 7, 1]
print(stringCollectionArgument.values)   // Prints ["Hello", "World"]

```
> The `values` property of an multivalued `Argument` always returns a non-nil array.

#### Custom validation of Options and Arguments
Both, `Option`'s and `Argument`'s are conform to the `CustomValidateable` protocol, which mean you can easy guard the validation of each of them by setting a closure to the `customValidation` property of them. If set this closure is invoked by the framework to guard the validation of the `Option` or `Argument`. When offering a closure you must return a case of the `ValidationResult` enumeration. This enumeraion contains two cases. One for success (`.success`) and one for a failing validation (`.fail(let message)`). Note that the latter one takes a `message` property which you can use to specify the reason of the validation failure.

##### ValidationResult

```swift
public enum ValidationResult {
    
    /// Case for successfully validation.
    case success
    /// Case for failing validation. Message contains reason of the failure.
    case fail(message: String)
}
```
##### Example of custom `Option` validation
Assuming we need a `NumberOption` that takes a value between `0` - `99`, e.g. to specify the age of an human. To validate that the the value is in the given range all we need to do is providing a closure to the `customValidation` property which guards that the value fits in the range.

```swift
let ageOption = NumberOption(name: "age", help: "Takes all `Int` values from 0 to 99")
        
ageOption.customValidation = {_ in
	if ageOption.value! < 0 || ageOption.value! > 99 {
		return .fail(message: "Value not in range 0 - 99.")
	} else {
		return .success
	}
}
```

```
$ example age 1										// SUCCEEDS
$ example age 99									// SUCCEEDS
$ example age 100                 // FAILS. "Value not in range 0 - 99."
```

### Required Arguments

Each `Argument` has the `isRequired` property; when setting to `true` true the `CommandLineInterface` would'nt parse successfully if any of the required arguments hasn't a valid value.

```swift
// The constructor of an argument takes the `required` flag 
let nameArgument = StringArgument(longFlag: "name", help: "Specify your name.", required: true)

// Alternatively you can set the property via it's getter / setter
nameArgument.isRequired = true

...

// Will only succeed if `nameArgument` has a valid `String` value ...
CommandLineInterface.parseOrExit()

```

### Options with required arguments
Each `Option` has the `requiredArguments` property specifying a collection of `Argument`'s that are required by this `Option`. When parsing the `CommandLineInterface` guards the specification of each `Argument` in the collection.

```swift
...

let resizeOption = FileOption(name: "resize", help: "Resizes the given image.")
let stretchHorizontalOption = FileOption(name: "stretchHorizontal", help: "Stretches the given image horizontally.")
        
let widthArgument = NumberArgument(shortFlag: "w", longFlag: "width", help: "The width of the output image")
let heightArgument = NumberArgument(shortFlag: "h", longFlag: "height", help: "The height of the output image")
        
        
// The resize option requires a value for both the width and the height argument
resizeOption.requiredArguments = [widthArgument, heightArgument]
        
// The stretch horizontal option requires a value for the width argument
stretchHorizontalOption.requiredArguments = [widthArgument]

...
```
```
$ example resize /Users/Bob/Desktop/Image.png -w 200 -h 200
$ example resize /Users/Bob/Desktop/Image.png -w 200               // FAILS. `resizeOption` needs both `-w` and `-h`
$ example resize /Users/Bob/Desktop/Image.png                      // FAILS. None of the required arguments are given

$ example stretchHorizontal /Users/Bob/Desktop/Image.png -w 400
$ example stretchHorizontal /Users/Bob/Desktop/Image.png -h 400    // FAILS. `stretchHorizontal` need the `-w` argument
```

### Default values for Arguments

Typed Arguments can have a default value. When set the default value is returned for a value if the value has not been set via the command line.

```swift
let argument = NumberArgument(longFlag: "num", defaultValue: 1)

...
print(argument.value) // Returns the default value if argument has not been specified
```
```
$ example             // Prints: 1
$ example --num 99    // Prints: 99
$ example --num       // FAILS. When naming the `--num` argument, you still need to set a value.
```

> `Arguments` providing a default value aren't required anymore due to they always return a valid value for the `value` property.

### Enum options

An `EnumOption<T>` takes a case of an enumeration `T` where `T` must be raw representable by `String`.

```swift
enum FileAction: String {
    case copy = "copy"
    case move = "move"
}

let fileActionOption = EnumOption<FileAction>(name: "fileAction", help: "Does something with files.")
let fileArgument = FileArgument(longFlag: "file")

fileActionOption.requiredArguments = [fileArgument]

// Will only succeed if `fileActionOption` has a valid case of `FileAction` and the `fileArgument` contains a valid value ...
CommandLineInterface.parseOrExit()

switch enumOption.value! {
case .copy:
    // Copy file specified in `fileArgument.value`
case .move:
    // Move file specified in `fileArgument.value`
}

...
```
```
$ example fileAction copy --file /Users/Bob/Documents/Curiculum_Vitae.pdf
$ example fileAction move --file /Users/Bob/Documents/Curiculum_Vitae.pdf

$ example fileAction share --file /Users/Bob/Documents/Curiculum_Vitae.pdf     // FAILS. `share` is not a case of FileAction
$ example fileAction --file /Users/Bob/Documents/Curiculum_Vitae.pdf           // FAILS. Missing value for `fileAction`
```
> `EnumOption`s are a good way to specify a collection of sub-options of an `Option`.

### Enum Arguments

An `EnumArgument<T>` takes a case of an enumeration `T` where `T` must be raw representable by `String`.

```swift
...

enum Language: String {
    case english
    case latin
    case spanish
    case turkish
}

let greetOption = StringOption(name: "greet", help: "Greet a person.")
let languageArgument = EnumArgument<Language>(longFlag: "lang")

// Will only succeed if `languageArgument` has a valid case of `Language` ...
CommandLineInterface.parseOrExit()

...

switch languageArgument.value! {
case .english:
    print("Hello \(greetOption.value!)")
case .latin:
    print("Salve \(greetOption.value!)")
case .spanish:
    print("Hola \(greetOption.value!)")
case .turkish:
    print("Merhaba \(greetOption.value!)")
}

...
```
```
$ example greet Max --lang english          // "Hello Max"
$ example greet Max --lang latin            // "Salve Max"
$ example greet Max --lang spanish          // "Hola Max"
$ example greet Max --lang turkish          // "Merhaba Max"

$ example greet Max --lang german           // FAILS. `german` is not a case of Language
$ example greet Max --lang                  // FAILS. No case for the language argument given.
```

### Parsing command line arguments

There are different ways to parse the given command line arguments. Do a parse and fetch rising errors for yourself or let us do the fetching by simple calling 'CommandLineInterface.parseOrExit()'.

```swift
...

do {
	// Throws potential parsing or validation error
	try CommandLineInterface.parse()
	
} catch let error {

	// Prints the error and exits the command line tool.  The `withHelp` argument specifies whether to print the manual page.
	CommandLineInterface.exit(withError: error, withHelp: true)
}

// Or simply call ...
CommandLineInterface.parseOrExit()

// You can pass your own collection of arguments to parse ...
CommandLineInterface.parse(["CLH", "option", "-myArgument", "myValue", "-v"])

...
```

## Features

### Options Catalog
| Type          | Value Type |
| ------------- |----------- |
| **`Option`** | |
| **`StringOption`** (`TypedOption<String>`) | `String` |
| **`NumberOption`** (`TypedOption<Int>`) | `Int` |
| **`DecimalOption`** (`TypedOption<Double>`) | `Double` |
| **`BoolOption`** (`TypedOption<Bool>`) | `Bool` |
| **`EnumOption<T>`** | `T` |
| **`FileOption`** (`TypedOption<URL>`) | `URL` |
| **`FolderOption `** (subclass of `FileOption` [=`TypedOption<URL>`] | `URL` |

### Arguments Catalog
| Type | Value Type | About |
| ---- |----------- | ----- |
| **`Argument`** | | The `isSelected` property of an `Argument` tells you whether it is included in the parsed arguments or not. |
| **`StringArgument`** | `String` |
| **`NumberArgument`** | `Int` | Parses the given value into an `Int`. It also takes negative values. |
| **`DecimalArgument`** | `Double` | Parses the given value into an `Double`. It also takes negative values.
| **`URLArgument`** | `URL ` | Parses the given value into a `URL`. The `URL` needs to be valid. |
| **`FileArgument`** | `URL ` | Parses the given value into a `URL` for a file. Guards the existence of the file. |
| **`FolderArgument`** | `URL ` | Parses the given value into a `URL` for a file. Guards the existence of the folder. You can even specify that the folder should be empty. |
| **`EnumArgument`** | `enum` | An `EnumArgument` takes the value of the specified enum type. |
| **`StringCollectionArgument`** | `[String]` | Parses the following values into `String`s. |
| **`NumberCollectionArgument`** | `[Int]` | Parses the following values into `Int`s. |
| **`DecimalCollectionArgument`** | `[Double]` | Parses the following arguments into `Double` values. |

### Custom Options and Arguments

The easiest way to create your own `Option`s or `Argument`s is to conform the type you want to parse from the command line to the `StringInitializable ` protocol.

```swift
protocol StringInitializable {
    init?(_ string: String) // Create a new instance with this constructor ...
}
```
By doing so you can use the build in classes `TypedOption<T: StringInitializable>` and `TypedArgument<T: StringInitializable>` to create a typealias and you are done.

```swift
// Option
typealias MyCustomOption = TypedOption<MyCustomType>

// Argument
typealias MyCustomArgument = TypedArgument<MyCustomType>
```

#### Example for a custom Option

For this example we want to create a `FloatOption`. An `Option` that takes a single `Float` value. All we need to do is extend `Float` about the conformance to the `StringInitializable` protocol ...

```swift
// Make Float conform to StringInitializable ...
extension Float: StringInitializable {
    public init?(string: String) {
    	self.init(string)
	}
}

// ... and create a typealias:
typealias FloatOption = TypedOption<Float>

...

// Now you can simply create a new instance ...
let floatOption = FloatOption(name: "floatOption", help: "Takes `Float` values.")

// ... and access the float value via ...
let floatValue: Float = floatOption.value!
```

### Configuration

You can configure the `CommandLineInterface` via the `configuration` property.

| Configuration | About |
| :------------ |:---------- |
| `.printHelpOnExit` | Prints the manual page when `CommandLineInterface`.exit(message:)` is called or the programm runs through without any actions. |
| `.needsValidOption`| When set the `parseOrExit()` function only passes if a valid `Option` was parsed. |
| `.printHelpForNoSelection` | When set the manual page is printet when no option could be parsed. |

### Manual Printer

The framework automatically prints a clean formatted manual page. The following image is the manual page for the [XcodeIconUtil](#https://github.com/lukasdanckwerth/XcodeIconUtil) command line tool.

<p align="center">
    <img src="https://gitlab.com/lukasdanckwerth/XcodeIconsUtil/raw/master/XcodeIconsUtilScreenshot.png" />
</p>

#### Custom Manual Printer

You can print a custom manual page if you want. The `CommandLineInterface` contains a `ManualPrinter` property which can be used to customize the output of the manual page. `ManualPrinter` is a typealias for a closure that should return the manual page string.



```swift
CommandLineInterface.defaul.manualPrinter = {CommandLineInterface in

	var manualContent = "My fancy manual"
            
	for option in CommandLineInterface.options {
    // add manual information
		manualContent += ...
	}
                                      
	for argument in CommandLineInterface.arguments {
    // add manual information
		manualContent += ...
	}
	
	return manualContent        
}
```

## Author
- [Lukas Danckwerth](https://github.com/lukasdanckwerth)

## Inspired by

- [Commander](https://github.com/kylef/Commander) by [kylef](https://github.com/kylef)
- [CommandLineKit](https://github.com/jatoben/CommandLine) by [jatoben](https://github.com/jatoben)

## Licence

Copyright (c) 2018-2019 Lukas Danckwerth.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

