//
//  CLConcreteOption.swift
//  
//
//  Created by Lukas Danckwerth on 31.05.20.
//

import Foundation

open class CLConcreteOption: CLOption, CLValidateable {
    
    public var description: String {
        return "Option[name=\(name)]"
    }
    
    /// Custom closure to validate this option.
    open var customValidation: (() -> CLValidationResult)?
    
    /// The name (and selector) of this option.
    open var name: String
    
    /// Describes the effect of this option.
    open var help: String?
    
    /// The collection of required arguments for this option.
    open var requiredArguments: [CLConcreteArgument]?
    
    /// Default initialization with the given arguments.
    ///
    /// - argument name: The name of the option.
    /// - argument description: Some help message describing the option.
    required public init(name: String, helpMessage: String? = nil) {
        self.name = name
        self.help = helpMessage
        CLInterface.default.options.append(self)
    }
    
    // MARK: - Equatable
    
    /// Returns `true` if the names of the given `Option`s are equal, `false` else.
    public static func ==(lhs: CLConcreteOption, rhs: CLConcreteOption) -> Bool {
        return lhs.name == rhs.name
    }
}
