//
//  CLCollectionArgument.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

open class CLCollectionArgument<Value: CLStringInitializable>: CLConcreteArgument, CLMultiValueContainer {
    
    /// Typealias for the `TypedValueable` protocol.
    public typealias ValueType = Value
    
    /// The default value of this option.
    ///
    var defaulValue: Any?
    
    /// Returns the type of the value of this argument.
    open var valueType: String {
        let typeString = "\("\(type(of: ValueType.self))".split(separator: ".").first ?? "")".uppercased()
        return "\(typeString)_1 \(typeString)_2 ..."
    }
    
    /// The collection of values of the argument.
    open var values: [ValueType] = []
    
    /// Validates the given value in raw value can be parsed to the expected type. Returns a `.fail(_)` response for an existend value
    /// or when the raw value can't be parsed.
    func parse(rawValue: String) -> CLValidationResult {
        
        guard let value = ValueType(rawValue) else {
            return .fail(message: "Can't parse raw value '\(rawValue)'.")
        }
        
        values.append(value)
        return .success
    }
}

/// Typealias for arguments which can take a collection of `String` values.
public typealias StringCollectionArgument = CLCollectionArgument<String>

/// Typealias for arguments which can take a collection of `Int` values.
public typealias NumberCollectionArgument = CLCollectionArgument<Int>

/// Typealias for arguments which can take a collection of `Double` values.
public typealias DecimalCollectionArgument = CLCollectionArgument<Double>
