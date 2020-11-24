//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 24.11.20.
//

import Foundation

protocol CLDefaultValueContainer {
    
    /// This container's default value.
    ///
    var defaultValue: Any? { get set }
    
    /// Returns a Boolean value indicating whether the container has a default value.
    ///
    var containsDefaultValue: Bool { get }
    
}

extension CLDefaultValueContainer {
    
    /// Returns a Boolean value indicating whether the container has a default value.
    ///
    var containsDefaultValue: Bool { self.defaultValue != nil }
    
}
