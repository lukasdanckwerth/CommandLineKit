//
//  CLTypeValueContainer.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Protocol for commands and arguments with values.
public protocol CLTypeValueContainer: CLValueContainer {
    
    /// Associated type of the value.
    associatedtype ValueType
    
    /// The value of this command.
    var value: ValueType! { get set }
    
    /// The default value of this command.
    var defaultValue: ValueType? { get set }
    
}

public extension CLTypeValueContainer {
    
    var valueType: String {
        return "\(type(of: ValueType.self))"
    }
}
