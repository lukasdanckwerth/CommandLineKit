//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 31.05.20.
//

import Foundation

// ===-----------------------------------------------------------------------------------------------------------===
//
// Domain `Argument`
// ===-----------------------------------------------------------------------------------------------------------===

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
