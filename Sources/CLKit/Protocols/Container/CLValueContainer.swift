//
//  CLValueContainer.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Protocol for commands and arguments with values.
///
public protocol CLValueContainer {
    
    /// Returns the type of the value of this command.
    ///
    var valueType: String { get }
    
    /// Tries to parse and validate the given raw value before setting it as value.
    ///
    func parse(rawValue: String) -> CLValidationResult
    
}

extension CLValueContainer {
    
    /// Returns `true` if the receiver contains a value in the `defaultValue` property.  Will
    /// return `false` if the property is `nil`.
    ///
    var containsDefaultValue: Bool { false }
    
}
