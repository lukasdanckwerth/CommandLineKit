//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 31.05.20.
//

import Foundation

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
