//
//  CLStringInitializableCommand.swift
//  
//
//  Created by Lukas Danckwerth on 24.11.20.
//

import Foundation

open class CLStringInitializableCommand<Value: CLStringInitializable>: CLValueCommand {
    
    /// Typealias for `CLTypeValueContainer` protocol.
    ///
    public typealias ValueType = Value
    
    /// The command's value.
    open var value: Value!
    
    /// The command's default value.
    open var defaultValue: Value?
    
    /// Validates the given value in `rawValue` can be parsed to the expected type.  Returns a `.fail(_)` response for an existend value
    /// or when the raw value can't be parsed.
    open func parse(rawValue: String) -> CLValidationResult {
        guard value == nil else { return .fail(message: "Single value command '\(name)' already contains a value '\(String(describing: value))'.") }
        value = Value(rawValue)
        guard value != nil else { return .fail(message: "Can't parse value: \(String(describing: rawValue))") }
        return .success
    }
}

/// A command line command which takes an `Int` value.
public typealias CLNumberCommand = CLStringInitializableCommand<Int>

/// A command line command which takes an `Double` value.
public typealias CLDecimalCommand = CLStringInitializableCommand<Double>

/// A command line command which takes an `String` value.
public typealias CLStringCommand = CLStringInitializableCommand<String>

/// A command line command which takes an `Bool` value.
public typealias CLBoolCommand = CLStringInitializableCommand<Bool>
