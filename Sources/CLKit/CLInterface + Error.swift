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
extension CLInterface {
    
    /// Defines the errors that can occure when using CommandLineInterface.
    public enum CLInterfaceError: Error {
        
        /// Thrown when no option is selected but the `needsValidOption` property is set to `true`.
        case noOptionSelected
        /// Thrown when an option already has been set but an other is found.
        case multipleOptionsSelected(option1: CLConcreteOption, option2: CLConcreteOption)
        
        /// Thrown for a failure in the validation of an selected option.
        case parseOptionFailure(option: CLConcreteOption, message: String)
        /// Thrown for an argument which value can't be parsed to the specifyed type.
        case parseArgumentFailure(argument: CLConcreteArgument, message: String)
        
        /// Thrown for a missing required value.
        case missingRequiredArgumentValue(argument: CLConcreteArgument)
        /// Thrown for a missing required value of an option.
        case missingRequiredOptionValue(option: CLConcreteOption)
        /// Thrown for a missing required argument.
        case missingRequiredArgument(option: CLConcreteOption, argument: CLConcreteArgument)
        /// Throws for an unknown argument.
        case unknownArgument(rawArgument: String)
        
        
        /// Thrown when a custom validation fails.
        case optionValidationFailure(option: CLConcreteOption, message: String)
        /// Thrown when a custom validation fails.
        case argumentValidationFailure(argument: CLConcreteArgument, message: String)
        
        
        public var localizedDescription: String {
            
            switch self {
            case .unknownArgument(let rawArgument):
                return "Unknown argument '\(rawArgument)'."
            case .noOptionSelected:
                return "No option selected."
            case .multipleOptionsSelected(let option1, let option2):
                return "Multiple options found. (first: \(option1.name), second: \(option2.name)"
            case .parseOptionFailure(let option, let message):
                return "Can't parse value of option '\(option.name)'.\n\(message)"
            case .parseArgumentFailure(let argument, let message):
                return "Can't parse value of argument '\(argument.longFlag)'.\n\(message)"
            case .missingRequiredArgument(let option, let argument):
                return "Missing required argument '\(argument.longFlag)' for option '\(option.name)'."
            case .missingRequiredOptionValue(let option):
                return "Missing required value for option '\(option.name)'."
            case .missingRequiredArgumentValue(let argument):
                return "Missing required value for argument '\(argument.longFlag)'."
            case .optionValidationFailure(_, let message):
                return "Error:  \(message)"
            case .argumentValidationFailure(_, let message):
                return "Error:  \(message)"
            }
        }
    }
}
