//
//  CLValidationResult + Extensions.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

extension CLValidationResult: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Bool
    public init(booleanLiteral value: Bool) {
        self = value ? .success : .fail(message: "Validation Invalid.")
    }
}

extension CLValidationResult: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self = .fail(message: value)
    }
}
