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
    
    /// Parse the given arguments.
    ///
    /// - argument rawArguments: The raw arguments to parse.
    open func parse(_ rawArguments: [String] = CommandLine.arguments) throws {
        
        self.rawArguments = rawArguments
        
        // guard the existance of at least one more argument than the programm path.
        if rawArguments.count <= 1 {
            if configuration.contains(.failOnMissingCommand) {
                throw CLInterfaceError.noCommandSelected
            }
            return
        }
        
        // clear any old selection
        command = nil
        selectedArguments = []
        unparsedArguments = []
        
        // index for iterating through the raw arguments
        var index = 1
        
        let commandNameCandidate = rawArguments[index]
        
        if let command = self.command(for: commandNameCandidate) {
            index += 1
            
            // Guard there is not command already set. This actually should never happen.
            guard self.command == nil else {
                throw CLInterfaceError.multipleCommandsSelected(command1: command, command2: command)
            }
            
            self.command = command
            
            if let valueContainer = command as? CLValueContainer {
                
                if rawArguments.valid(index: index) {
                    
                    let commandValueCandidate = rawArguments[index]
                    
                    // parse command value
                    let validationResult = valueContainer.parse(rawValue: commandValueCandidate)
                    
                    switch validationResult {
                    case .success:
                        break
                    case .fail(let message):
                        throw CLInterfaceError.parseCommandFailure(command: command, message: message)
                    }
                    
                    index += 1
                    
                } else if command.containsDefaultValue == false {
                    throw CLInterfaceError.parseCommandFailure(
                        command: command,
                        message: "Missing required value for command '\(command.name)'."
                    )
                }
            }
            
        } else if configuration.contains(.failOnMissingCommand) {
            throw CLInterfaceError.noCommandSelected
        }
        
        while index < rawArguments.count {
            
            let token = rawArguments[index]
            
            if let parsedArgument = try parseArgument(token: token, at: &index, ofArguments: rawArguments) {
                selectedArguments.append(parsedArgument)
            }
            
            else if token.hasPrefix(CLInterface.prefixShortFlag), !token.hasPrefix(CLInterface.prefixLongFlag) {
                for char in token.replacingOccurrences(of: CLInterface.prefixShortFlag, with: "") {
                    
                    if let parsedArgument = try parseArgument(token: "\(CLInterface.prefixShortFlag)\(char)", at: &index, ofArguments: rawArguments) {
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
        
        guard let argument = self.argument(for: token) else { return nil }
        argument.isSelected = true
        
        if let valuedArgument = argument as? CLValueContainer {
            
            try validateNextItem(atIndex: index, inArray: arguments, argument: argument)
            
            // Counter that guards at least one token has been ate ...
            var foundValues = 0
            
            while arguments.valid(index: index + 1) && self.argument(for: arguments[index + 1]) == nil {
                
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
        
        return argument
    }
    
    /// Guards the possible selected command passes its validation if any existing and iterates through
    /// the arguments and validates that every required argument has a valid value.
    private func validate() throws {
        
        if let requiredArguments = command?.requiredArguments {
            for requiredArgument in requiredArguments {
                
                guard selectedArguments.contains(requiredArgument)
                        || (requiredArgument as? CLValueContainer)?.containsDefaultValue == true else {
                    throw CLInterfaceError.missingRequiredArgument(
                        command: command!,
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
        
        // if there is a custom command validation guard it passes successfully.
        if let customValidation = command?.validation {
            switch customValidation() {
            case .success:
                break
            case .fail(let message):
                throw CLInterfaceError.commandValidationFailure(command: command, message: message)
            }
        }
        
        // check custom validation on selected arguments
        for argument in selectedArguments {
            if let customValidation = argument.validation {
                switch customValidation() {
                case .success:
                    break
                case .fail(let message):
                    throw CLInterfaceError.argumentValidationFailure(argument: argument, message: message)
                }
            }
        }
    }
    
    /// Parses the arguments from the command line given in `CommandLine.arguments` and dies with an error message.
    ///
    public func parseOrExit() {
        do { try parse() }
        catch let error { CLInterface.exit(
            withError: error,
            printManual: configuration.contains(.printManualOnFailure))
        }
    }
    
    /// Returns the `CLCommand` for the given selector.
    ///
    public func command(for selector: String) -> CLCommand? {
        return commands.first(where: { $0.name == selector })
    }
    
    /// Returns the `CLConcreteArgument` for the given selector.
    ///
    public func argument(for selector: String) -> CLConcreteArgument? {
        return arguments.first(where: { $0.longFlag == selector || $0.shortFlag == selector })
    }
}

internal extension Array {
    func valid(index: Int) -> Bool { index > 0 && index < count }
}
