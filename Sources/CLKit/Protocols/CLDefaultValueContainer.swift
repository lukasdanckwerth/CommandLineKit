//
//  CLBaseValueContainerb.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

protocol CLDefaultValueContainer {
    
    /// The default value of this option.
    ///
    var defaulValue: Any? { get set }
    
}

extension CLDefaultValueContainer {
    
    /// Returns `true` if the receiver contains a value in the `defaulValue` property.  Will
    /// return `false` if the property is `nil`.
    ///
    var containsDefaultValue: Bool { defaulValue != nil }
    
}
