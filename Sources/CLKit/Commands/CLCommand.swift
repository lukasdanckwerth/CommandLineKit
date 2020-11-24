//
//  CLCommand.swift
//  
//
//  Created by Lukas Danckwerth on 23.11.20.
//

import Foundation

open class CLCommand {
    
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
    /// - argument name: The name of the option.
    /// - argument help: Some help message describing the option.
    ///
    required public init(name: String, help: String? = nil) {
        self.name = name
        self.help = help
        CLInterface.default.commands.append(self)
    }
    
    // MARK: - CLValidateable
    
    /// Custom closure to validate this command.
    ///
    open var customValidation: (() -> CLValidationResult)?
    
    
    
    // MARK: - Equatable
    
    /// Returns `true` if the names of the given commands are equal, `false` else.
    ///
    public static func ==(lhs: CLCommand, rhs: CLCommand) -> Bool {
        return lhs.name == rhs.name
    }
    
    
    // MARK: - CustomStringConvertible
    
    /// A textual representation of this instance.
    ///
    public var description: String {
        return "\(type(of: self))[name=\(name)]"
    }
}
