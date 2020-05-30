//
//  CommandLineKit.swift
//  CommandLineKit
//
//  Created by Lukas Danckwerth on 18.06.19.
//  Copyright © 2019 Lukas Danckwerth. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Darwin
import Foundation

/***********************************************************************************************************************
 *
 * Extensions and global functions
 ***********************************************************************************************************************/

/// Return an iterator with all enum cases of the given enum type.
fileprivate func iterateEnum<T: Hashable>(_: T?) -> AnyIterator<T> {
   var i = 0
   return AnyIterator { let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
      if next.hashValue != i { return nil }
      i += 1
      return next
   }
}

fileprivate extension String {
   
   /// Returns this string in a form which will be printed as bold in the terminal.
   var bold: String {
      return "\u{001B}[1m\(self)\u{001B}[0m"
   }
}

// MARK: - StringInitializable -

/// Protocol that can be implemented by types you want to parse from the command line.
public protocol StringInitializable {
   
   /// Initializes this value from the given string argument.
   init?(_ string: String)
}

extension Int: StringInitializable { }

extension Double: StringInitializable { }

extension Bool: StringInitializable { }

extension String: StringInitializable { }

extension URL: StringInitializable {
   
   public init?(_ string: String) { self.init(string: string) }
}


// MARK: - ValidationResult -

/// Enumeration of validation results.
public enum ValidationResult {
   
   /// Case for successfully validation.
   case success
   /// Case for validation failure.  Message contains more info.
   case fail(message: String)
}

extension ValidationResult: ExpressibleByBooleanLiteral {
   
   public typealias BooleanLiteralType = Bool
   
   public init(booleanLiteral value: Bool) {
      self = value ? .success : .fail(message: "")
   }
}

// MARK: - Protocols

/// Protocol for validation.
protocol CustomValidateable {
   
   /// Custom closure to validate the `CustomValidateable`.
   var customValidation: (() -> ValidationResult)? { get set }
}

/// Protocol for options and arguments with values.
protocol Valueable {
   
   /// Returns the type of the value of this option.
   var valueType: String { get }
   
   /// Tries to parse and validate the given raw value before setting it as value.
   func parse(rawValue: String) -> ValidationResult
}

protocol BaseValueable {
   
   /// The default value of this option.
   var baseDefaultValue: Any? { get set }
}

/// Protocol for options and arguments with values.
protocol TypedValueable: Valueable {
   
   /// Associated type.
   associatedtype ValueType
   
   /// The value of this option.
   var value: ValueType! { get set }
   
   /// The default value of this option.
   var defaultValue: ValueType? { get set }
}

/// Protocol for options and arguments with values.
protocol TypedMultiValueable: Valueable {
   
   /// Associated type.
   associatedtype ValueType
   
   /// The value of this option.
   var values: [ValueType] { get set }
}

protocol OptionProtocol: Equatable, CustomStringConvertible {
   
   /// The name (and selector) of this option.
   var name: String { get set }
   
   /// Describes the effect of this option.
   var helpMessage: String? { get set }
   
   /// The collection of required arguments for this option.
   var requiredArguments: [Argument]? { get set }
   
   /// Default initialization with the given arguments.
   ///
   /// - argument name:        The name of the option.
   /// - argument helpMessage: Some help message describing the option.
   init(name: String, helpMessage: String?)
}

// ===-----------------------------------------------------------------------------------------------------------===
//
// Domain `Option`
// ===-----------------------------------------------------------------------------------------------------------===

// MARK: - Option -

open class Option: OptionProtocol, CustomValidateable {
   
   public var description: String {
      return "Option[name=\(name)]"
   }
   
   /// Custom closure to validate this option.
   open var customValidation: (() -> ValidationResult)?
   
   /// The name (and selector) of this option.
   open var name: String
   
   /// Describes the effect of this option.
   open var helpMessage: String?
   
   /// The collection of required arguments for this option.
   open var requiredArguments: [Argument]?
   
   /// Default initialization with the given arguments.
   ///
   /// - argument name: The name of the option.
   /// - argument description: Some help message describing the option.
   required public init(name: String, helpMessage: String? = nil) {
      self.name = name
      self.helpMessage = helpMessage
      CommandLineInterface.default.options.append(self)
   }
   
   // MARK: - Equatable
   
   /// Returns `true` if the names of the given `Option`s are equal, `false` else.
   public static func ==(lhs: Option, rhs: Option) -> Bool {
      return lhs.name == rhs.name
   }
}

extension Option {
   @objc var containsDefaultValue: Bool { false }
}

open class TypedOption<Value: StringInitializable>: Option, TypedValueable {
   
   /// Typealias for `TypedValueable` protocol
   public typealias ValueType = Value
   
   /// The value of this option
   public var value: Value!
   
   /// The default value of this option
   public var defaultValue: Value?
   
   /// Returns the type of the value of this option
   open var valueType: String {
      return "\(type(of: value))"
   }
   
   @objc override var containsDefaultValue: Bool { defaultValue != nil }
   
   /// Validates the given value in `rawValue` can be parsed to the expected type.  Returns a `.fail(_)` response for an existend value
   /// or when the raw value can't be parsed.
   func parse(rawValue: String) -> ValidationResult {
      guard value == nil else { return .fail(message: "Single value option '\(name)' already contains a value '\(String(describing: value))'.") }
      value = Value(rawValue)
      guard value != nil else { return .fail(message: "Can't parse value: \(String(describing: rawValue))") }
      return .success
   }
}

open class EnumOption<EnumType: RawRepresentable>: Option, TypedValueable where EnumType.RawValue == String, EnumType: Hashable {
   
   /// Typealias for `TypedValueable` protocol.
   typealias ValueType = EnumType
   
   /// The enum value of this option.
   public var value: EnumType!
   
   /// The default value of this option.
   public var defaultValue: EnumType?
   
   @objc override var containsDefaultValue: Bool { defaultValue != nil }
   
   /// Returns the type of the value of this option.
   open var valueType: String {
      return iterateEnum(value).map({ return "'\($0)'" }).joined(separator: ", ")
   }
   
   /// Validates the given value in raw value can be parsed to the expected type. Returns a `.fail(_)` response for an existend value
   /// or when the raw value can't be parsed.
   func parse(rawValue: String) -> ValidationResult {
      guard value == nil else { return .fail(message: "Single value option '\(name)' already contains a value '\(String(describing: value))'.") }
      value = EnumType(rawValue: rawValue)
      guard value != nil else { return .fail(message: "Can't parse value: \(String(describing: rawValue))") }
      return .success
   }
}

/// A command line option which takes an `Int` value.
public typealias NumberOption = TypedOption<Int>
/// A command line option which takes an `Double` value.
public typealias DecimalOption = TypedOption<Double>
/// A command line option which takes an `String` value.
public typealias StringOption = TypedOption<String>
/// A command line option which takes an `Bool` value.
public typealias BoolOption = TypedOption<Bool>

/// Option for files.
open class FileOption: TypedOption<URL> {
   
   /// A Boolean value indicating whether the file must exists.
   open var isExsitenceRequired: Bool = false
   
   /// A Boolean value indicating whether this option translates relative to absolute paths.
   open var isTransformsRelativeToAbsolute: Bool = true
   
   /// Returns the type of the value ('FILE_PATH') of this argument.
   override open var valueType: String { return "FILE_PATH" }
   
   /// Default initialization with the given arguments.
   ///
   /// - parameter name:             The name of the option.
   /// - parameter description:      Some help message describing the option.
   /// - parameter requireExistence: A Boolean value indicating whether the file must exist.
   convenience public init(name: String, help: String? = nil, fileExistenceRequired: Bool = false) {
      self.init(name: name, helpMessage: help)
      isExsitenceRequired = fileExistenceRequired
   }
   
   /// Validates the given value in raw value can be parsed to the expected type. Returns a `.fail(_)` response for an existend value
   /// or when the raw value can't be parsed.
   override func parse(rawValue: String) -> ValidationResult {
      var rawValue = rawValue
      guard value == nil else { return .fail(message: "Single value option '\(name)' already contains a value '\(String(describing: value))'.") }
      if isTransformsRelativeToAbsolute {
         if rawValue.hasPrefix("./") {
            rawValue.removeFirst(2)
            rawValue = "\(FileManager.default.currentDirectoryPath)/\(rawValue)"
         } else if !rawValue.hasPrefix("/") {
            rawValue = "\(FileManager.default.currentDirectoryPath)/\(rawValue)"
         }
      }
      guard let escapedPath = rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
         return .fail(message: "Can't add percent encoding for raw value: \(String(describing: rawValue))")
      }
      value = URL(string: escapedPath)
      guard value != nil else { return .fail(message: "Can't parse value: \(String(describing: rawValue))") }
      return validate(value: value!)
   }
   
   /// Dependant on the `isExsitenceRequired` property this function validates the existence of the file.
   fileprivate func validate(value: URL) -> ValidationResult {
      guard isExsitenceRequired else { return .success }
      
      var isDir : ObjCBool = false
      if FileManager.default.fileExists(atPath: value.path, isDirectory: &isDir) {
         return !isDir.boolValue ? .success : .fail(message: "Expected file but found folder '\(value.absoluteString)'.")
      } else {
         return .fail(message: "File doesn't exist '\(value.path)'.")
      }
   }
}

/// Option for Folders.
open class FolderOption: FileOption {
   
   /// Returns the type of the value ('FOLDER_PATH') of this argument.
   override open var valueType: String { return "FOLDER_PATH" }
   
   /// Dependant on the `isExsitenceRequired` property this function validates the existence of the file.
   override func validate(value: URL) -> ValidationResult {
      guard isExsitenceRequired else { return .success }
      
      var isDir : ObjCBool = false
      if FileManager.default.fileExists(atPath: value.absoluteString, isDirectory: &isDir) {
         return isDir.boolValue ? .success : .fail(message: "Expected folder but found file '\(value.absoluteString)'.")
      } else {
         return .fail(message: "Folder doesn't exist '\(value.absoluteString)'.")
      }
   }
}

// ===-----------------------------------------------------------------------------------------------------------===
//
// Domain `Argument`
// ===-----------------------------------------------------------------------------------------------------------===

// MARK: - ArgumentProtocol -

protocol ArgumentProtocol: Equatable, CustomStringConvertible {
   
   /// Short flag of the argument. A `String` in the form of '-{FLAG_CHAR}'
   var shortFlag: String? { get set }
   
   /// Long flag of the argument. A `String` in the form of '--{FLAG_NAME}'.
   var longFlag: String { get set }
   
   /// Describes the effect of this option.
   var helpMessage: String? { get set }
   
   /// A Boolean value indicating whether this argument is required.
   var isRequired: Bool { get set }
   
   /// Default initialization with the given parameters.
   ///
   /// - parameter shortFlag:   The short flag of the argument.
   /// - parameter longFlag:    The long flag of the argument.
   /// - parameter help:        Some help message describing the option.
   /// - parameter required:    A Boolean value indicating whether this argument is required.
   init(shortFlag: String?, longFlag: String, help: String?, required: Bool)
}

// MARK: - Argument -

open class Argument: ArgumentProtocol, CustomValidateable {
   
   public var description: String {
      return "Argument[\(longFlag), \(shortFlag ?? ""), isRequired: \(isRequired)]"
   }
   
   /// Custom closure to validate this option.String?
   open var customValidation: (() -> ValidationResult)?
   
   /// Short flag of the argument. A `String` in the form of '-{FLAG_CHAR}'
   open var shortFlag: String?
   
   /// Long flag of the argument. A `String` in the form of '--{FLAG_NAME}'.
   open var longFlag: String
   
   /// A help message describing the usage of the argument.
   open var helpMessage: String?
   
   /// A Boolean value indicating whether this argument is required. Default is `false`.
   open var isRequired: Bool = false
   
   /// A Boolean value indicating whether this argument is inclued in the selected arguments.
   open var isSelected: Bool = false
   
   /// Default initialization with the given parameters.
   ///
   /// - parameter shortFlag:   The short flag of the argument. Nilable
   /// - parameter longFlag:    The long flag of the argument.
   /// - parameter helpMessage: Some help message describing the option. Nilable
   /// - parameter required:    A Boolean value indicating whether this `Argument` is required. Default is `false`.
   /// - parameter autoAdd:     A Boolean value indicating whether this `Argument` is added to the default `CommandLineInterface` on initialization.
   required public init(shortFlag: String? = nil, longFlag: String, help: String? = nil, required: Bool = false) {
      self.shortFlag = shortFlag != nil ? (shortFlag!.hasPrefix("-") ? shortFlag : "-\(shortFlag!)") : nil
      self.longFlag = longFlag.hasPrefix("--") ? longFlag : "--\(longFlag)"
      self.helpMessage = help
      self.isRequired = required
      CommandLineInterface.default.arguments.append(self)
   }
   
   // MARK: - Equatable
   
   /// Returns `true` if the name of the given `Argument`s is equal.
   public static func ==(lhs: Argument, rhs: Argument) -> Bool {
      return lhs.shortFlag == rhs.shortFlag && lhs.longFlag == rhs.longFlag
   }
}

// MARK: - TypedArgument
open class TypedArgument<ValueType: StringInitializable>: Argument, TypedValueable, BaseValueable {
   
   override public var description: String {
      return "TypedArgument[\(longFlag), \(shortFlag ?? ""), value: \(String(describing: value)), defaultValue: \(String(describing: defaultValue)), isRequired: \(isRequired)]"
   }
   
   /// The underlying internal value of this argument.
   fileprivate var internalValue: ValueType?
   
   /// The value of the argument.
   public var value: ValueType! {
      get { return internalValue ?? defaultValue }
      set { internalValue = newValue }
   }
   
   /// The default value of this option.
   internal var baseDefaultValue: Any?
   
   /// The default value of the argument.
   public var defaultValue: ValueType? {
      get { return baseDefaultValue as? ValueType }
      set { baseDefaultValue = newValue }
   }
   
   /// Returns the type of the value of this argument.
   open var valueType: String { return "\("\(type(of: ValueType.self))".split(separator: ".").first ?? "")".uppercased() }
   
   public convenience init(shortFlag: String? = nil, longFlag: String, help: String? = nil, required: Bool = false, defaultValue: ValueType? = nil) {
      self.init(shortFlag: shortFlag, longFlag: longFlag, help: help, required: required)
      self.defaultValue = defaultValue
   }
   
   /// Validates the given value in raw value can be parsed to the expected type. Returns a `.fail(_)` response for an existend value
   /// or when the raw value can't be parsed.
   func parse(rawValue: String) -> ValidationResult {
      guard internalValue == nil else { return .fail(message: "Single value argument '\(longFlag)' already contains a value '\(String(describing: value))'.") }
      internalValue = ValueType(rawValue)
      guard internalValue != nil else { return .fail(message: "Can't parse raw value: \(String(describing: rawValue))") }
      return .success
   }
}

// ===-----------------------------------------------------------------------------------------------------------===
//
// Concrete `Argument`s implementations
// ===-----------------------------------------------------------------------------------------------------------===

// MARK: - Typealiases

/// Typealias for arguments whith a `String` value.
public typealias StringArgument = TypedArgument<String>
/// Typealias for arguments whith an `Int` value.
public typealias NumberArgument = TypedArgument<Int>
/// Typealias for arguments whith a `Double` value.
public typealias DecimalArgument = TypedArgument<Double>
/// Typealias for arguments whith a `URL` value.
public typealias URLArgument = TypedArgument<URL>

// MARK: - EnumArgument
/// Argument which takes an enum case.
open class EnumArgument<EnumType: RawRepresentable>: Argument, TypedValueable, BaseValueable where EnumType.RawValue == String, EnumType: Hashable {
   
   /// Typealias for the `TypedValueable` protocol.
   typealias ValueType = EnumType
   
   /// The underlying internal value of this argument.
   private var internalValue: EnumType?
   
   /// The value of the argument.
   open var value: EnumType! {
      get { return internalValue ?? defaultValue }
      set { internalValue = newValue }
   }
   
   /// The default value of this option.
   open var baseDefaultValue: Any?
   
   /// The default value of the argument.
   open var defaultValue: EnumType? {
      get { return baseDefaultValue as? EnumType }
      set { baseDefaultValue = newValue }
   }
   
   /// Returns the type of the value of this argument.
   open var valueType: String { return iterateEnum(value).map({ return "'\($0)'" }).joined(separator: ", ") }
   
   public convenience init(shortFlag: String? = nil, longFlag: String, help: String? = nil, required: Bool = false, defaultValue: EnumType? = nil) {
      self.init(shortFlag: shortFlag, longFlag: longFlag, help: help, required: required)
      self.defaultValue = defaultValue
   }
   
   /// Validates the given value in raw value can be parsed to the expected type. Returns a `.fail(_)` response for an existend value
   /// or when the raw value can't be parsed.
   public func parse(rawValue: String) -> ValidationResult {
      guard internalValue == nil else { return .fail(message: "Single value argument '\(longFlag)' already contains a value '\(String(describing: value))'.") }
      internalValue = EnumType(rawValue: rawValue)
      guard internalValue != nil else { return .fail(message: "Can't parse raw value: \(String(describing: rawValue))") }
      return .success
   }
}

// MARK: - FileArgument
/// Argument which takes a path to a file.
open class FileArgument: URLArgument {
   
   /// A Boolean value indicating whether the file must exists.
   var isExsitenceRequired: Bool = false
   
   /// Returns the type of the value ('FILE_PATH') of this argument.
   override open var valueType: String { return "FILE_PATH" }
   
   override func parse(rawValue: String) -> ValidationResult {
      var rawValue = rawValue
      guard internalValue == nil else { return .fail(message: "Single value argument '\(longFlag)' already contains a value '\(String(describing: value))'.") }
      if rawValue.hasPrefix("./") {
         rawValue.removeFirst(2)
         rawValue = "\(FileManager.default.currentDirectoryPath)/\(rawValue)"
      } else if !rawValue.hasPrefix("/") {
         rawValue = "\(FileManager.default.currentDirectoryPath)/\(rawValue)"
      }
      guard let escapedPath = rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
         return .fail(message: "Can't add percent encoding for raw value: \(String(describing: rawValue))")
      }
      internalValue = URL(fileURLWithPath: escapedPath)
      guard internalValue != nil else { return .fail(message: "Can't parse raw value: \(String(describing: rawValue))") }
      return validate(value: internalValue!)
   }
   
   /// If `isExsitenceRequired` is set to `true` this func guards the existence of a file a the path of the given `URL`.
   fileprivate func validate(value: URL) -> ValidationResult {
      if isExsitenceRequired && !FileManager.default.fileExists(atPath: value.absoluteString) {
         return .fail(message: "Required file doesn't exist (\(value.absoluteString)).")
      }
      return .success
   }
}

// MARK: - FolderArgument
/// Argument which takes a path to a folder.
open class FolderArgument: FileArgument {
   
   /// Returns the type of the value ('FOLDER_PATH') of this argument.
   override open var valueType: String { return "FOLDER_PATH" }
   
   /// If `isExsitenceRequired` is set to `true` this func guards the existence of a folder a the path of the given `URL`.
   fileprivate override func validate(value: URL) -> ValidationResult {
      var isDir : ObjCBool = false
      if isExsitenceRequired && !FileManager.default.fileExists(atPath: value.absoluteString, isDirectory: &isDir) {
         return isDir.boolValue ? .success : .fail(message: "Required folder doesn't exist (\(value.absoluteString)).")
      }
      return .success
   }
}

// MARK: - CollectionArgument
open class CollectionArgument<Value: StringInitializable>: Argument, TypedMultiValueable {
   
   /// Typealias for the `TypedValueable` protocol.
   public typealias ValueType = Value
   
   /// Returns the type of the value of this argument.
   open var valueType: String {
      let typeString = "\("\(type(of: ValueType.self))".split(separator: ".").first ?? "")".uppercased()
      return "\(typeString)_1 \(typeString)_2 ..."
   }
   
   /// The collection of values of the argument.
   open var values: [ValueType] = []
   
   /// Validates the given value in raw value can be parsed to the expected type. Returns a `.fail(_)` response for an existend value
   /// or when the raw value can't be parsed.
   func parse(rawValue: String) -> ValidationResult {
      
      guard let value = ValueType(rawValue) else {
         return .fail(message: "Can't parse raw value '\(rawValue)'.")
      }
      
      values.append(value)
      return .success
   }
}

/// Typealias for arguments which can take a collection of `String` values.
public typealias StringCollectionArgument = CollectionArgument<String>
/// Typealias for arguments which can take a collection of `Int` values.
public typealias NumberCollectionArgument = CollectionArgument<Int>
/// Typealias for arguments which can take a collection of `Double` values.
public typealias DecimalCollectionArgument = CollectionArgument<Double>

// ===-----------------------------------------------------------------------------------------------------------===
//
// Core (CommandLineInterface)
// ===-----------------------------------------------------------------------------------------------------------===

// MARK: - CommandLineInterface -

public class CommandLineInterface {
   
   
   // MARK: - Error enumeration
   
   /// Defines the errors that can occure when using CommandLineInterface.
   public enum CommandLineInterfaceError: Error {
      
      /// Thrown when no option is selected but the `needsValidOption` property is set to `true`.
      case noOptionSelected
      /// Thrown when an option already has been set but an other is found.
      case multipleOptionsSelected(option1: Option, option2: Option)
      
      /// Thrown for a failure in the validation of an selected option.
      case parseOptionFailure(option: Option, message: String)
      /// Thrown for an argument which value can't be parsed to the specifyed type.
      case parseArgumentFailure(argument: Argument, message: String)
      
      /// Thrown for a missing required value.
      case missingRequiredArgumentValue(argument: Argument)
      /// Thrown for a missing required value of an option.
      case missingRequiredOptionValue(option: Option)
      /// Thrown for a missing required argument.
      case missingRequiredArgument(option: Option, argument: Argument)
      /// Throws for an unknown argument.
      case unknownArgument(rawArgument: String)
      
      
      /// Thrown when a custom validation fails.
      case optionValidationFailure(option: Option, message: String)
      /// Thrown when a custom validation fails.
      case argumentValidationFailure(argument: Argument, message: String)
   }
   
   
   // MARK: - Sinleton and convenient static accessors
   
   /// Default instance
    public static var `default`: CommandLineInterface! = CommandLineInterface(name: "Default")
   
   /// The name of the command line tool.
   public static var name: String {
      get { return CommandLineInterface.default.name }
      set { CommandLineInterface.default.name = newValue }
   }
   
   /// The selected option parsed from the command line. May be `nil`.
   public static var option: Option! {
      get { return CommandLineInterface.default.option }
      set { CommandLineInterface.default.option = newValue }
   }
   
   
   public static var configuration: Configuration {
      get { return CommandLineInterface.default.configuration }
      set { CommandLineInterface.default.configuration = newValue }
   }
   
   /// Prints the generated help page for this command line tool.
   public static func printHelp() {
      CommandLineInterface.default.printManual()
   }
   
   /// The prefix used for short flags of `Argument`s.
   public static var prefixShortFlag = "-"
   /// The prefix used for long flags of `Argument`s.
   public static var prefixLongFlag = "--"
   
   
   // MARK: - Properties
   
   /// The name of the command line tool.
   open var name: String = ""
   /// Describes the command line tool.
   open var about: String?
   
   open var version: String = "0"
   
   /// Contains the raw arguments as received from the `parse(_ rawArguments: [String])` function.
   private(set) var rawArguments: [String]?
   /// After calling `parse()`, this property will contain any values that weren't captured by an `Option` or `Argument`.
   private(set) lazy var unparsedArguments: [String] = []
   
   /// The underlying array of arguments.
   open var arguments: [Argument] = []
   /// The underlying array of arguments.
   open var options: [Option] = []
   /// Returns an array containing the short and long flags of the arguments.
   fileprivate var allPossibleArgumentNames: [String] {
      
      return arguments.filter({
         return $0.shortFlag != nil
      }).map({
         return $0.shortFlag!
      }) + arguments.map({
         return $0.longFlag
      })
   }
   
   /// The selected option parsed from the command line. May be `nil`.
   open var option: Option!
   /// The selected arguments parsed from the command line.
   open var selectedArguments: [Argument] = []
   
   /// A closure to print a custom help manual page.
   open var manualPrinter: ManualPrinter?
   
   
   // MARK: - Configuration
   
   /// Describes the configuration of a `CommandLineInterface`.
   public class Configuration: OptionSet {
      
      required public init(rawValue: Int) {
         self.rawValue = rawValue
      }
      
      /// The raw `Int` value of this configuration.
      public let rawValue: Int
      
      /// Indicates whether to always print the help message after error messages
      public static let printHelpOnExit = Configuration(rawValue: 1)
      /// Indicates whether a valid option is needed to be specifyed to execute.rawValue
      public static let failOnMissingOption = Configuration(rawValue: 1 << 1)
      /// Prints the help page in case no `Option` has been specified
      public static let printHelpForNoSelection = Configuration(rawValue: 1 << 3)
      /// Allow unknown raw arguments
      public static let allowUnknownArguments = Configuration(rawValue: 1 << 4)
   }
   
   /// The configuration set
   public var configuration: Configuration = []
   
   
   // MARK: - Initialization
   
   public init(name: String, version: String = "0", about: String? = nil, configuration: Configuration = []) {
      self.name = name
      self.version = version
      self.about = about
      self.configuration = configuration
      CommandLineInterface.default = self
   }
   
   /// Validates that the given array has at least one more index than the given one.
   ///
   /// - argument atIndex: The index to check the next element exists.
   /// - argument inArray: The array to check.
   /// - argument argument: The arguemnt for printing some help message on failure.
   private func validateNextItem(atIndex: Int, inArray: Array<Any>, argument: Argument) throws {
      guard (atIndex + 1) < inArray.count else {
         throw CommandLineInterfaceError.missingRequiredArgumentValue(argument: argument)
      }
   }
   
   /// Parses the arguments from the command line given in `CommandLine.arguments` and dies with an error message.
   public static func parseOrExit() {
      CommandLineInterface.default.parseOrExit()
   }
   
   /// Parses the arguments from the command line given in `CommandLine.arguments` and dies with an error message.
   public func parseOrExit() {
      do { try parse() }
      catch let error { CommandLineInterface.exit(
         withError: error,
         printManual: CommandLineInterface.default.configuration.contains(.printHelpOnExit))
      }
   }
   
   /// Parse the given arguments.
   ///
   /// - argument arguments: The arguments to parse.
   public static func parse(_ arguments: [String]) throws {
      try CommandLineInterface.default.parse(arguments)
   }
   
   /// Parse the given arguments.
   ///
   /// - argument rawArguments: The raw arguments to parse.
   open func parse(_ rawArguments: [String] = CommandLine.arguments) throws {
      
      if configuration.contains(.failOnMissingOption), rawArguments.count <= 1 {
         throw CommandLineInterfaceError.noOptionSelected
      }
      
      // guard the existance of at least one more argument than the programm path.
      guard rawArguments.count > 1 else { return }
      
      self.rawArguments = rawArguments
      
      // clear any old selection
      option = nil
      selectedArguments = []
      unparsedArguments = []
      
      // index for iterating through the raw arguments
      var index = 1
      
      // check for possible option first
      if rawArguments.count > index {
         
         let optionNameCandidate = rawArguments[index]
         
         for option in options {
            
            if option.name == optionNameCandidate {
               
               // Guard there is not option already set. This actually should never happen.
               guard self.option == nil else {
                  throw CommandLineInterfaceError.multipleOptionsSelected(option1: option, option2: option)
               }
               self.option = option
               
               if let valueableOption = option as? Valueable {
                  
                  if (index + 1) < rawArguments.count {
                     
                     index += 1
                     let optionValue = rawArguments[index]
                     guard !allPossibleArgumentNames.contains(optionValue) else {
                        throw CommandLineInterfaceError.missingRequiredOptionValue(option: option)
                     }
                     
                     // Validate the set value.
                     let validationResult = valueableOption.parse(rawValue: optionValue)
                     
                     switch validationResult {
                     case .success:
                        break
                     case .fail(let message):
                        throw CommandLineInterfaceError.optionValidationFailure(option: option, message: message)
                     }
                     
                  } else if option.containsDefaultValue {
                     // empty
                  } else {
                     throw CommandLineInterfaceError.parseOptionFailure(
                        option: option,
                        message: "Missing required value for option '\(option.name)'."
                     )
                  }
               }
               
               index += 1
               break
            }
         }
      } else {
         throw CommandLineInterfaceError.noOptionSelected
      }
      
      // guard no valid option is needed or we got a valid one.
      guard !configuration.contains(.failOnMissingOption) || option != nil else {
         throw CommandLineInterfaceError.noOptionSelected
      }
      
      while index < rawArguments.count {
         
         let token = rawArguments[index]
         
         if let parsedArgument = try parseArgument(token: token, at: &index, ofArguments: rawArguments) {
            selectedArguments.append(parsedArgument)
         } else if token.hasPrefix("-"), !token.hasPrefix("--") {
            
            for char in token.replacingOccurrences(of: "-", with: "") {
               
               if let parsedArgument = try parseArgument(token: "-\(char)", at: &index, ofArguments: rawArguments) {
                  selectedArguments.append(parsedArgument)
               } else {
                  throw CommandLineInterfaceError.unknownArgument(rawArgument: token)
               }
            }
            
         } else if configuration.contains(.allowUnknownArguments) {
            // if unknown arguments allowed add the unknown token to the collection of unparsed arguments.
            unparsedArguments.append(token)
         } else {
            throw CommandLineInterfaceError.unknownArgument(rawArgument: token)
         }
         
         index += 1
      }
      
      try validate()
   }
   
   private func parseArgument(token: String, at index: inout Int, ofArguments arguments: [String]) throws -> Argument? {
      
      for argument in self.arguments {
         
         // Check for a valid token.
         if (argument.shortFlag == token || argument.longFlag == token) {
            
            if let valuedArgument = argument as? Valueable {
               
               try validateNextItem(atIndex: index, inArray: arguments, argument: argument)
               // Counter that guards at least one token has been ate ...
               var foundValues = 0
               
               while (index + 1) < arguments.count && !allPossibleArgumentNames.contains(arguments[index + 1]) {
                  index += 1
                  
                  // Validate the token can be parsed ...
                  let parseValidationResult = valuedArgument.parse(rawValue: arguments[index])
                  
                  switch parseValidationResult {
                  case .success:
                  break // Nothing to do
                  case .fail(let message):
                     throw CommandLineInterfaceError.parseArgumentFailure(argument: argument, message: message)
                  }
                  foundValues += 1
               }
               
               guard foundValues > 0 else {
                  throw CommandLineInterfaceError.missingRequiredArgumentValue(argument: argument)
               }
            }
            
            argument.isSelected = true
            
            return argument
         }
      }
      return nil
   }
   
   /// Guards the possible selected option passes its validation if any existing and iterates through
   /// the arguments and validates that every required argument has a valid value.
   private func validate() throws {
      
      if let requiredArguments = option?.requiredArguments {
         for requiredArgument in requiredArguments {
            guard selectedArguments.contains(requiredArgument)
               || (requiredArgument as? BaseValueable)?.baseDefaultValue != nil else {
                  throw CommandLineInterfaceError.missingRequiredArgument(
                     option: option!,
                     argument: requiredArgument
                  )
            }
         }
      }
      
      // Guard the existence of the values for all required arguments
      for argument in arguments {
         if argument.isRequired && !selectedArguments.contains(argument) {
            throw CommandLineInterfaceError.missingRequiredArgumentValue(argument: argument)
         }
      }
      
      // if there is a custom option validation guard it passes successfully.
      if let customValidation = option?.customValidation {
         switch customValidation() {
         case .success:
            break
         case .fail(let message):
            throw CommandLineInterfaceError.optionValidationFailure(option: option, message: message)
         }
      }
      
      // check custom validation on selected arguments
      for argument in selectedArguments {
         if let customValidation = argument.customValidation {
            switch customValidation() {
            case .success:
               break
            case .fail(let message):
               throw CommandLineInterfaceError.argumentValidationFailure(argument: argument, message: message)
            }
         }
      }
   }
   
   /// Prints the generated manual page for this command line tool. If the `manualPrinter` property is set it will use the output
   /// of the sepecified printer (if it's not `nil`).  Will print the default manual page generated by `CommandLineInterface` else.
   public func printManual() {
      Swift.print(manualPrinter?(self) ?? CommandLineInterface.defaulManualPrinter(self) ?? "No manual page.", "\n")
   }
   
   /// Prints the given message and exits the programm.
   ///
   /// - argument message:      The message to pring before exit.
   /// - argument printManual:  Boolean value indication whether to print the help page before exit.
   /// - argument exitCode:     The exit code wich will be used as a parameter for the `Foundation.exit(int)` function.
   public static func exit(_ message: String, printManual: Bool = false, exitCode: Int32 = EXIT_SUCCESS) -> Never {
      Swift.print(exitCode == EXIT_FAILURE ? "Error: \(message)\n" : "\(message)\n")
      if printManual || configuration.contains(.printHelpOnExit) { printHelp() }
      Foundation.exit(exitCode)
   }
   
   /// Print a message for the given error and exits the command line tool.
   ///
   /// - argument withError:    The error that leads to the exit of the command line tool.
   /// - argument printManual:  Boolean value indication whether to print the help page before exit.
   public static func exit(withError error: Error, printManual flag: Bool = false) -> Never {
      guard let commandLineInterfaceError = error as? CommandLineInterfaceError else {
         exit("\(error)", printManual: flag)
      }
      
      switch commandLineInterfaceError {
      case .noOptionSelected:
         exit("No option selected.", printManual: flag || configuration.contains(.printHelpForNoSelection))
      default:
         exit(string(from: error), printManual: flag)
      }
   }
   
   /// Returns an error message for the given `Error`.
   ///
   /// - returns: A string containing the error message.
   public static func string(from error: Error) -> String {
      
      guard let commandLineInterfaceError = error as? CommandLineInterfaceError else {
         return "Unknown Error"
      }
      
      switch commandLineInterfaceError {
      case .unknownArgument(let rawArgument):
         return "Unknown argument '\(rawArgument)'."
      case .noOptionSelected:
         return "No option selected."
      case .multipleOptionsSelected(let option1, let option2):
         return "Multiple options found. (first: \(option1.name), second: \(option2.name)"
      case .parseOptionFailure(let option, let message):
         return "Can't parse value of option '\(option.name)'.\n\(message)"
      case .parseArgumentFailure(let argument, let message):
         return "Can't parse value of argument '\(argument.longFlag)'.\n\(message)"
      case .missingRequiredArgument(let option, let argument):
         return "Missing required argument '\(argument.longFlag)' for option '\(option.name)'."
      case .missingRequiredOptionValue(let option):
         return "Missing required value for option '\(option.name)'."
      case .missingRequiredArgumentValue(let argument):
         return "Missing required value for argument '\(argument.longFlag)'."
      case .optionValidationFailure(_, let message):
         return "Error:  \(message)"
      case .argumentValidationFailure(_, let message):
         return "Error:  \(message)"
      }
   }
}

// MARK: - Manual Printer -

extension CommandLineInterface {
   
   
   /// Typealias for a closure to print the help manual page.
   public typealias ManualPrinter = (CommandLineInterface) -> String?
   
   /// The default printer for the manual page.
   public static var defaulManualPrinter: ManualPrinter {
      
      return { cli in
         
         func addWhitespaceIfNeeded(_ input: String) -> String {
            return input + ((input.hasSuffix(" ") || input.hasSuffix("\n") || input.hasSuffix("\t")) ? "" : " ")
         }
         
         var printMessage = "Usage: \(cli.name)"
         
         if cli.options.count > 0 { printMessage += " [option]" }
         if cli.arguments.count > 0 { printMessage += " [arguments]" }
         printMessage += "\n"
         
         if let about = cli.about {
            printMessage += "\n\(about)"
         }
         
         if cli.options.count > 0 {
            printMessage += "\n# OPTIONS:\n"
            for option in cli.options {
               
               printMessage += "\n\t" + option.name.bold
               
               if let valueableOption = option as? Valueable {
                  
                  // actually very dirrty.
                  printMessage += " \(valueableOption.valueType)"
                     .replacingOccurrences(of: "Optional<", with: "")
                     .replacingOccurrences(of: ">", with: "")
               }
               
               if let helpMessage = option.helpMessage {
                  printMessage += "\n\t\t\(helpMessage)"
               }
               
               if let requiredArguments = option.requiredArguments {
                  printMessage = addWhitespaceIfNeeded(printMessage) + "(Requires \(requiredArguments.map({arg in arg.longFlag.bold }).joined(separator: ", ")))"
               }
            }
            printMessage += "\n"
         }
         
         if cli.arguments.count > 0 {
            printMessage += "\n# ARGUMENTS:\n"
            for argument in cli.arguments {
               
               printMessage += "\n\t" + (argument.shortFlag != nil ? "\(argument.shortFlag!.bold), \(argument.longFlag.bold)" : argument.longFlag.bold)
               
               if let typedArgument = argument as? Valueable {
                  let valueType = typedArgument.valueType
                  if valueType.contains(" ") {
                     printMessage += "   [\(typedArgument.valueType)]"
                  } else {
                     printMessage += "   \(typedArgument.valueType)"
                  }
               }
               
               if let helpMessage = argument.helpMessage { printMessage += "\n\t\t\(helpMessage) " }
               
               if let defaultValue = (argument as? BaseValueable)?.baseDefaultValue {
                  printMessage = addWhitespaceIfNeeded(printMessage) + "(Default is '\(defaultValue)')"
               } else if argument.isRequired {
                  printMessage = addWhitespaceIfNeeded(printMessage) + "(Required)"
               }
            }
         }
         
         return printMessage
      }
   }
}


// MARK: - DEBUG AREA -

#if DEBUG
extension CommandLineInterface {
   
   func reset() {
      
      selectedArguments = []
      option = nil
      
      arguments = []
      options = []
   }
   
   func getStats() -> String {
      return """
      Name: \(name)
      Configuration: \(configuration)
      
      Tokens: \(String(describing: rawArguments))
      
      Options: \(options)
      Arguments: \(arguments)
      
      Selected Option: \(String(describing: option))
      Selected Arguments: \(selectedArguments)
      """
   }
}
#endif

// Idee: UserDefaultsOption
