//
//  CLStringInitializableArgument.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

open class CLStringInitializableArgument<ValueType: CLStringInitializable>: CLConcreteArgument, CLTypeValueContainer {
    
    override public var description: String {
        return "TypedArgument[\(longFlag), \(shortFlag ?? ""),"
            + " value: \(String(describing: value)),"
            + " defaultValue: \(String(describing: internalDefaultValue)),"
            + " isRequired: \(isRequired)]"
    }
    
    /// The underlying internal value of this argument.
    internal var internalValue: ValueType?
    
    /// The default value of this command.
    internal var internalDefaultValue: Any?
    
    /// The value of the argument.
    public var value: ValueType! {
        get { return internalValue ?? internalDefaultValue as? ValueType }
        set { internalValue = newValue }
    }
    
    /// The default value of the argument.
    public var defaultValue: ValueType? {
        get { return internalDefaultValue as? ValueType }
        set { internalDefaultValue = newValue }
    }
    
    /// Returns the type of the value of this argument.
    open var valueType: String {
        return "\("\(type(of: ValueType.self))".split(separator: ".").first ?? "")".uppercased()
    }
    
    public convenience init(shortFlag: String? = nil, longFlag: String, help: String? = nil, required: Bool = false, defaultValue: ValueType? = nil) {
        self.init(shortFlag: shortFlag, longFlag: longFlag, help: help, required: required)
        self.internalDefaultValue = defaultValue
    }
    
    /// Validates the given value in raw value can be parsed to the expected type. Returns a `.fail(_)` response for an existend value
    /// or when the raw value can't be parsed.
    public func parse(rawValue: String) -> CLValidationResult {
        guard internalValue == nil else { return .fail(message: "Single value argument '\(longFlag)' already contains a value '\(String(describing: value))'.") }
        internalValue = ValueType(rawValue)
        guard internalValue != nil else { return .fail(message: "Can't parse raw value: \(String(describing: rawValue))") }
        return .success
    }
}
