//
//  CLTypeValueContainer.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Protocol for options and arguments with values.
protocol CLTypeValueContainer: CLValueContainer {
    
    /// Associated type of the value.
    associatedtype ValueType
    
    /// The value of this option.
    var value: ValueType! { get set }
    
    /// The default value of this option.
    var defaultValue: ValueType? { get set }
    
}

extension CLTypeValueContainer {
    
    var valueType: String {
        return "\(type(of: ValueType.self))"
    }
}
