//
//  CLValueContainer.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Protocol for options and arguments with values.
protocol CLValueContainer {
    
    /// Returns the type of the value of this option.
    var valueType: String { get }
    
    /// Tries to parse and validate the given raw value before setting it as value.
    func parse(rawValue: String) -> CLValidationResult
}
