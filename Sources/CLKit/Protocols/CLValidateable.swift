//
//  CLValidateable.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Protocol for validation.
///
public protocol CLValidateable {
    
    /// Custom closure to validate the `CLValidateable`.
    ///
    var validation: (() -> CLValidationResult)? { get set }
    
}
