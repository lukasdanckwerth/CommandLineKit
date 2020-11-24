//
//  CLArgumentProtocol.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

public protocol CLArgumentProtocol: CLValidateable, Equatable, CustomStringConvertible {
    
    /// Short flag of the argument. A `String` in the form of '-{FLAG_CHAR}'
    var shortFlag: String? { get set }
    
    /// Long flag of the argument. A `String` in the form of '--{FLAG_NAME}'.
    var longFlag: String { get set }
    
    /// Describes the effect of this command.
    var help: String? { get set }
    
    /// A Boolean value indicating whether this argument is required.
    var isRequired: Bool { get set }
    
    /// Default initialization with the given parameters.
    ///
    /// - parameter shortFlag:   The short flag of the argument.
    /// - parameter longFlag:    The long flag of the argument.
    /// - parameter help:        Some help message describing the command.
    /// - parameter required:    A Boolean value indicating whether this argument is required.
    init(shortFlag: String?, longFlag: String, help: String?, required: Bool)
    
}
