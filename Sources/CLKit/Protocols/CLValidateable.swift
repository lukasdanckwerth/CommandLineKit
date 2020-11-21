//
//  CLValidateable.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Protocol for validation.
///
protocol CLValidateable {
    
    /// Custom closure to validate the `CLValidateable`.
    ///
    var customValidation: (() -> CLValidationResult)? { get set }
    
}
