//
//  CLCommandProtocol.swift
//  
//
//  Created by Lukas Danckwerth on 31.05.20.
//

import Foundation

public protocol CLCommandProtocol: CLValidateable, Equatable, CustomStringConvertible {
    
    /// The name (and selector) of this option.
    var name: String { get set }
    
    /// Describes the effect of this option.
    var help: String? { get set }
    
    /// The collection of required arguments for this option.
    var requiredArguments: [CLConcreteArgument]? { get set }
    
    /// Default initialization with the given arguments.
    ///
    /// - argument name:        The name of the option.
    /// - argument help: Some help message describing the option.
    init(name: String, helpMessage: String?)
    
}
