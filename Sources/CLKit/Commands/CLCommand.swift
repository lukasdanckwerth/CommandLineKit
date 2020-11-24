//
//  CLCommand.swift
//  
//
//  Created by Lukas Danckwerth on 23.11.20.
//

import Foundation

open class CLCommand: CLCommandProtocol {
    
    /// The name (and selector) of this command.
    ///
    open var name: String
    
    /// Describes the effect of this command.
    ///
    open var help: String?
    
    /// The collection of required arguments for this command.
    ///
    open var requiredArguments: [CLConcreteArgument]?
    
    /// Default initialization with the given arguments.
    ///
    /// - argument name: The name of the command.
    /// - argument help: Some help message describing the command.
    ///
    public required init(name: String, help: String? = nil) {
        self.name = name
        self.help = help
        CLInterface.default.commands.append(self)
    }
    
    
    // MARK: - CLValidateable
    
    /// Custom closure to validate this command.
    ///
    open var validation: (() -> CLValidationResult)?
    
    
    // MARK: - Equatable
    
    /// Returns `true` if the names of the given commands are equal, `false` if not.
    ///
    public static func ==(lhs: CLCommand, rhs: CLCommand) -> Bool {
        return lhs.name == rhs.name
    }
}
