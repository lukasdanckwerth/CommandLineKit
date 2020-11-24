//
//  CLEnumCommand.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

open class CLEnumCommand<EnumType: RawRepresentable>: CLCommand, CLTypeValueContainer where EnumType.RawValue == String, EnumType: Hashable {
    
    /// Typealias for `TypedValueable` protocol.
    public typealias ValueType = EnumType
    
    /// The default value of this command.
    ///
    open var defaultValue: EnumType?
    
    /// The enum value of this command.
    open var value: EnumType!
    
    /// Returns the type of the value of this command.
    open var valueType: String {
        return iterateEnum(value).map({ return "'\($0)'" }).joined(separator: ", ")
    }
    
    /// Validates the given value in raw value can be parsed to the expected type. Returns a `.fail(_)` response for an existend value
    /// or when the raw value can't be parsed.
    public func parse(rawValue: String) -> CLValidationResult {
        guard value == nil else { return .fail(message: "Single value command '\(name)' already contains a value '\(String(describing: value))'.") }
        value = EnumType(rawValue: rawValue)
        guard value != nil else { return .fail(message: "Can't parse value: \(String(describing: rawValue))") }
        return .success
    }
}
