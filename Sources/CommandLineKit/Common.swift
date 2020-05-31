//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 31.05.20.
//

import Foundation

// ===-----------------------------------------------------------------------------------------------------------===
//
// MARK: - ValidationResult
// ===-----------------------------------------------------------------------------------------------------------===

/// Enumeration of validation results.
public enum ValidationResult {
    
    /// Case for successfully validation.
    case success
    /// Case for validation failure.  Message contains more info.
    case fail(message: String)
}

extension ValidationResult: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Bool
    public init(booleanLiteral value: Bool) {
        self = value ? .success : .fail(message: "Validation Invalid.")
    }
}

extension ValidationResult: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self = .fail(message: value)
    }
}



// ===-----------------------------------------------------------------------------------------------------------===
//
// MARK: - Iterate Enumerations
// ===-----------------------------------------------------------------------------------------------------------===

/// Return an iterator with all enum cases of the given enum type.
func iterateEnum<T: Hashable>(_: T?) -> AnyIterator<T> {
    var i = 0
    return AnyIterator { let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}



// ===-----------------------------------------------------------------------------------------------------------===
//
// MARK: - String Extension
// ===-----------------------------------------------------------------------------------------------------------===

extension String {
    
    /// Returns this string in a form which will be printed as bold in the terminal.
    var bold: String {
        return "\u{001B}[1m\(self)\u{001B}[0m"
    }
}
