//
//  CLInterface + Parse.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

extension CLInterface {
    
    /// Validates that the given array has at least one more index than the given one.
    ///
    /// - argument atIndex: The index to check the next element exists.
    /// - argument inArray: The array to check.
    /// - argument argument: The arguemnt for printing some help message on failure.
    private func validateNextItem(atIndex: Int, inArray: Array<Any>, argument: CLConcreteArgument) throws {
        guard (atIndex + 1) < inArray.count else {
            throw CLInterfaceError.missingRequiredArgumentValue(argument: argument)
        }
    }
    
    /// Parses the arguments from the command line given in `CommandLine.arguments` and dies with an error message.
    public func parseOrExit() {
        do { try parse() }
        catch let error { CLInterface.exit(
            withError: error,
            printHelp: CLInterface.default.configuration.contains(.printHelpOnExit))
        }
    }
    
    /// Parse the given arguments.
    ///
    /// - argument rawArguments: The raw arguments to parse.
    open func parse(_ rawArguments: [String] = CommandLine.arguments) throws {
        
        if configuration.contains(.failOnMissingOption), rawArguments.count <= 1 {
            throw CLInterfaceError.noOptionSelected
        }
        
        // guard the existance of at least one more argument than the programm path.
        guard rawArguments.count > 1 else { return }
        
        self.rawArguments = rawArguments
        
        // clear any old selection
        option = nil
        selectedArguments = []
        unparsedArguments = []
        
        // index for iterating through the raw arguments
        var index = 1
        
        // check for possible option first
        if rawArguments.count > index {
            
            let optionNameCandidate = rawArguments[index]
            
            for option in options {
                
                if option.name == optionNameCandidate {
                    
                    // Guard there is not option already set. This actually should never happen.
                    guard self.option == nil else {
                        throw CLInterfaceError.multipleOptionsSelected(option1: option, option2: option)
                    }
                    self.option = option
                    
                    if let valueableOption = option as? CLValueContainer {
                        
                        if (index + 1) < rawArguments.count {
                            
                            index += 1
                            let optionValue = rawArguments[index]
                            guard !allPossibleArgumentNames.contains(optionValue) else {
                                throw CLInterfaceError.missingRequiredOptionValue(option: option)
                            }
                            
                            // Validate the set value.
                            let validationResult = valueableOption.parse(rawValue: optionValue)
                            
                            switch validationResult {
                            case .success:
                                break
                            case .fail(let message):
                                throw CLInterfaceError.parseOptionFailure(option: option, message: message)
                            }
                            
                        } else if option.containsDefaultValue {
                            // empty
                        } else {
                            throw CLInterfaceError.parseOptionFailure(
                                option: option,
                                message: "Missing required value for option '\(option.name)'."
                            )
                        }
                    }
                    
                    index += 1
                    break
                }
            }
        } else {
            throw CLInterfaceError.noOptionSelected
        }
        
        // guard no valid option is needed or we got a valid one.
        guard !configuration.contains(.failOnMissingOption) || option != nil else {
            throw CLInterfaceError.noOptionSelected
        }
        
        while index < rawArguments.count {
            
            let token = rawArguments[index]
            
            if let parsedArgument = try parseArgument(token: token, at: &index, ofArguments: rawArguments) {
                selectedArguments.append(parsedArgument)
            } else if token.hasPrefix("-"), !token.hasPrefix("--") {
                
                for char in token.replacingOccurrences(of: "-", with: "") {
                    
                    if let parsedArgument = try parseArgument(token: "-\(char)", at: &index, ofArguments: rawArguments) {
                        selectedArguments.append(parsedArgument)
                    } else {
                        throw CLInterfaceError.unknownArgument(rawArgument: token)
                    }
                }
                
            } else if configuration.contains(.allowUnknownArguments) {
                // if unknown arguments allowed add the unknown token to the collection of unparsed arguments.
                unparsedArguments.append(token)
            } else {
                throw CLInterfaceError.unknownArgument(rawArgument: token)
            }
            
            index += 1
        }
        
        try validate()
    }
    
    private func parseArgument(token: String, at index: inout Int, ofArguments arguments: [String]) throws -> CLConcreteArgument? {
        
        for argument in self.arguments {
            
            // Check for a valid token.
            if (argument.shortFlag == token || argument.longFlag == token) {
                
                if let valuedArgument = argument as? CLValueContainer {
                    
                    try validateNextItem(atIndex: index, inArray: arguments, argument: argument)
                    // Counter that guards at least one token has been ate ...
                    var foundValues = 0
                    
                    while (index + 1) < arguments.count && !allPossibleArgumentNames.contains(arguments[index + 1]) {
                        index += 1
                        
                        // Validate the token can be parsed ...
                        let parseValidationResult = valuedArgument.parse(rawValue: arguments[index])
                        
                        switch parseValidationResult {
                        case .success:
                        break // Nothing to do
                        case .fail(let message):
                            throw CLInterfaceError.parseArgumentFailure(argument: argument, message: message)
                        }
                        foundValues += 1
                    }
                    
                    guard foundValues > 0 else {
                        throw CLInterfaceError.missingRequiredArgumentValue(argument: argument)
                    }
                }
                
                argument.isSelected = true
                
                return argument
            }
        }
        return nil
    }
    
    /// Guards the possible selected option passes its validation if any existing and iterates through
    /// the arguments and validates that every required argument has a valid value.
    private func validate() throws {
        
        if let requiredArguments = option?.requiredArguments {
            for requiredArgument in requiredArguments {
                guard selectedArguments.contains(requiredArgument)
                    || (requiredArgument as? CLBaseValueContainer)?.baseDefaultValue != nil else {
                        throw CLInterfaceError.missingRequiredArgument(
                            option: option!,
                            argument: requiredArgument
                        )
                }
            }
        }
        
        // Guard the existence of the values for all required arguments
        for argument in arguments {
            if argument.isRequired && !selectedArguments.contains(argument) {
                throw CLInterfaceError.missingRequiredArgumentValue(argument: argument)
            }
        }
        
        // if there is a custom option validation guard it passes successfully.
        if let customValidation = option?.customValidation {
            switch customValidation() {
            case .success:
                break
            case .fail(let message):
                throw CLInterfaceError.optionValidationFailure(option: option, message: message)
            }
        }
        
        // check custom validation on selected arguments
        for argument in selectedArguments {
            if let customValidation = argument.customValidation {
                switch customValidation() {
                case .success:
                    break
                case .fail(let message):
                    throw CLInterfaceError.argumentValidationFailure(argument: argument, message: message)
                }
            }
        }
    }
}
