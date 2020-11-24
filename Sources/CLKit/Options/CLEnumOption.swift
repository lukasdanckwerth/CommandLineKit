//
//  CLEnumOption.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

open class CLEnumOption<EnumType: RawRepresentable>: CLConcreteOption, CLTypeValueContainer where EnumType.RawValue == String, EnumType: Hashable {
    
    /// Typealias for `TypedValueable` protocol.
    typealias ValueType = EnumType
    
    /// The enum value of this option.
    public var value: EnumType!
    
    /// The default value of this option.
    public var defaultValue: EnumType?
    
    var containsDefaultValue: Bool { defaultValue != nil }
    
    /// Returns the type of the value of this option.
    open var valueType: String {
        return iterateEnum(value).map({ return "'\($0)'" }).joined(separator: ", ")
    }
    
    /// Validates the given value in raw value can be parsed to the expected type. Returns a `.fail(_)` response for an existend value
    /// or when the raw value can't be parsed.
    func parse(rawValue: String) -> CLValidationResult {
        guard value == nil else { return .fail(message: "Single value option '\(name)' already contains a value '\(String(describing: value))'.") }
        value = EnumType(rawValue: rawValue)
        guard value != nil else { return .fail(message: "Can't parse value: \(String(describing: rawValue))") }
        return .success
    }
}
