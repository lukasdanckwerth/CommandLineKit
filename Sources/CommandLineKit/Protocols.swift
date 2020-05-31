//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 31.05.20.
//

import Foundation

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


// MARK: - Protocols

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
    
    /// Associated type of the value.
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



// ===-----------------------------------------------------------------------------------------------------------===
//
// MARK: - OptionProtocol
// ===-----------------------------------------------------------------------------------------------------------===

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
// MARK: - ArgumentProtocol
// ===-----------------------------------------------------------------------------------------------------------===

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



// ===-----------------------------------------------------------------------------------------------------------===
//
// MARK: - CustomValidateable
// ===-----------------------------------------------------------------------------------------------------------===

/// Protocol for validation.
protocol CustomValidateable {
    
    /// Custom closure to validate the `CustomValidateable`.
    var customValidation: (() -> ValidationResult)? { get set }
}
