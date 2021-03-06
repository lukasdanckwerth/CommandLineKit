//
//  CLEnumArgument.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Argument which takes an enum case.
open class CLEnumArgument<EnumType: RawRepresentable>: CLConcreteArgument, CLTypeValueContainer where EnumType.RawValue == String, EnumType: Hashable {
    
    /// Typealias for the `TypedValueable` protocol.
    public typealias ValueType = EnumType
    
    /// The underlying internal value of this argument.
    internal var internalValue: EnumType?
    
    
    /// The default value of this command.
    internal var internalDefaultValue: Any?
    
    /// The value of the argument.
    open var value: EnumType! {
        get { return internalValue ?? internalDefaultValue as? EnumType }
        set { internalValue = newValue }
    }

    /// The default value of the argument.
    open var defaultValue: EnumType? {
        get { return internalDefaultValue as? EnumType }
        set { internalDefaultValue = newValue }
    }
    
    /// Returns the type of the value of this argument.
    open var valueType: String { return iterateEnum(value).map({ return "'\($0)'" }).joined(separator: ", ") }
    
    public convenience init(shortFlag: String? = nil, longFlag: String, help: String? = nil, required: Bool = false, defaultValue: EnumType? = nil) {
        self.init(shortFlag: shortFlag, longFlag: longFlag, help: help, required: required)
        self.defaultValue = defaultValue
    }
    
    /// Validates the given value in raw value can be parsed to the expected type. Returns a `.fail(_)` response for an existend value
    /// or when the raw value can't be parsed.
    public func parse(rawValue: String) -> CLValidationResult {
        guard internalValue == nil else { return .fail(message: "Single value argument '\(longFlag)' already contains a value '\(String(describing: value))'.") }
        internalValue = EnumType(rawValue: rawValue)
        guard internalValue != nil else { return .fail(message: "Can't parse raw value: \(String(describing: rawValue))") }
        return .success
    }
}
