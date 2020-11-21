//
//  CLValidationResult.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Enumeration of validation results.
public enum CLValidationResult {
    
    /// Case for successfully validation.
    case success
    
    /// Case for validation failure.  Message contains more info.
    case fail(message: String)
    
}
