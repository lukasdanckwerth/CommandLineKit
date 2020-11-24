//
//  CLInterface + Error.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

// ===-----------------------------------------------------------------------------------------------------------===
//
// MARK: - Errors
// ===-----------------------------------------------------------------------------------------------------------===

/// Defines the errors that can occure when using CommandLineInterface.
public enum CLInterfaceError {
    
    /// Thrown when no command is selected but the `needsValidCommand` property is set to `true`.
    case noCommandSelected
    /// Thrown when an command already has been set but an other is found.
    case multipleCommandsSelected(command1: CLCommand, command2: CLCommand)
    
    /// Thrown for a failure in the validation of an selected command.
    case parseCommandFailure(command: CLCommand, message: String)
    /// Thrown for an argument which value can't be parsed to the specifyed type.
    case parseArgumentFailure(argument: CLConcreteArgument, message: String)
    
    /// Thrown for a missing required value.
    case missingRequiredArgumentValue(argument: CLConcreteArgument)
    /// Thrown for a missing required value of an command.
    case missingRequiredCommandValue(command: CLCommand)
    /// Thrown for a missing required argument.
    case missingRequiredArgument(command: CLCommand, argument: CLConcreteArgument)
    /// Throws for an unknown argument.
    case unknownArgument(rawArgument: String)
    
    
    /// Thrown when a custom validation fails.
    case commandValidationFailure(command: CLCommand, message: String)
    /// Thrown when a custom validation fails.
    case argumentValidationFailure(argument: CLConcreteArgument, message: String)
    
}

extension CLInterfaceError: Error {
    
    var description: String {
        return localizedDescription
    }
    
    var localizedDescription: String {
        
        switch self {
        case .unknownArgument(let rawArgument):
            return "Unknown argument '\(rawArgument)'."
        case .noCommandSelected:
            return "No command selected."
        case .multipleCommandsSelected(let command1, let command2):
            return "Multiple commands found. (first: \(command1.name), second: \(command2.name)"
        case .parseCommandFailure(let command, let message):
            return "Can't parse value of command '\(command.name)'.\n\(message)"
        case .parseArgumentFailure(let argument, let message):
            return "Can't parse value of argument '\(argument.longFlag)'.\n\(message)"
        case .missingRequiredArgument(let command, let argument):
            return "Missing required argument '\(argument.longFlag)' for command '\(command.name)'."
        case .missingRequiredCommandValue(let command):
            return "Missing required value for command '\(command.name)'."
        case .missingRequiredArgumentValue(let argument):
            return "Missing required value for argument '\(argument.longFlag)'."
        case .commandValidationFailure(_, let message):
            return "Error:  \(message)"
        case .argumentValidationFailure(_, let message):
            return "Error:  \(message)"
        }
    }
}
