//
//  CLCustomValidateable.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Protocol for validation.
protocol CLCustomValidateable {
    
    /// Custom closure to validate the `CLCustomValidateable`.
    var customValidation: (() -> CLValidationResult)? { get set }
}
