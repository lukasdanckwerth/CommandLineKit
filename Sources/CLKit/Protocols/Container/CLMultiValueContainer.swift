//
//  CLMultiValueContainer.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Protocol for commands and arguments with values.
protocol CLMultiValueContainer: CLValueContainer {
    
    /// Associated type.
    associatedtype ValueType
    
    /// The value of this command.
    var values: [ValueType] { get set }
    
}
