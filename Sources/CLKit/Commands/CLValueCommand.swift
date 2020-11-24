//
//  CLValueCommand.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

open class CLValueCommand<Value: CLStringInitializable>: CLCommand, CLTypeValueContainer {
    
    /// Typealias for `TypedValueable` protocol
    public typealias ValueType = Value
    
    /// The default value of this option.
    ///
    var defaulValue: Any?
    
    /// The value of this option
    public var value: Value!
    
    /// The default value of this option
    public var defaultValue: Value?
    
    /// Returns the type of the value of this option
    open var valueType: String {
        return "\(type(of: value))"
    }
    
    var containsDefaultValue: Bool { defaultValue != nil }
    
    /// Validates the given value in `rawValue` can be parsed to the expected type.  Returns a `.fail(_)` response for an existend value
    /// or when the raw value can't be parsed.
    func parse(rawValue: String) -> CLValidationResult {
        guard value == nil else { return .fail(message: "Single value option '\(name)' already contains a value '\(String(describing: value))'.") }
        value = Value(rawValue)
        guard value != nil else { return .fail(message: "Can't parse value: \(String(describing: rawValue))") }
        return .success
    }
}

/// A command line option which takes an `Int` value.
public typealias CLNumberCommand = CLValueCommand<Int>

/// A command line option which takes an `Double` value.
public typealias CLDecimalCommand = CLValueCommand<Double>

/// A command line option which takes an `String` value.
public typealias CLStringCommand = CLValueCommand<String>

/// A command line option which takes an `Bool` value.
public typealias CLBoolCommand = CLValueCommand<Bool>
