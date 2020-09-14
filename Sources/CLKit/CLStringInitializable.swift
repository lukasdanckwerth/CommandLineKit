//
//  CLStringInitializable.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Protocol that can be implemented by types you want to parse from the command line.
public protocol CLStringInitializable {
    
    /// Initializes this value from the given string argument.
    init?(_ string: String)
}
