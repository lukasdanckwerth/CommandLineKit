//
//  CLInterface.swift
//  CommandLineKit (CLKit)
//
//  Created by Lukas Danckwerth on 18.06.19.
//  Copyright © 2019 Lukas Danckwerth. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Darwin
import Foundation

// ===-----------------------------------------------------------------------------------------------------------===
//
// Core (CLInterface)
// ===-----------------------------------------------------------------------------------------------------------===

open class CLInterface {
    
    // MARK: - Sinleton and convenient static accessors
    
    /// Default instance
    public static var `default`: CLInterface = CLInterface(name: "Default")
    
    /// The name of the command line tool.
    public static var name: String {
        get { return CLInterface.default.name }
        set { CLInterface.default.name = newValue }
    }
    
    /// The selected option parsed from the command line. May be `nil`.
    public static var option: CLConcreteOption! {
        get { return CLInterface.default.option }
        set { CLInterface.default.option = newValue }
    }
    
    public static var configuration: CLConfiguration {
        get { return CLInterface.default.configuration }
        set { CLInterface.default.configuration = newValue }
    }
    
    /// Prints the generated help page for this command line tool.
    public static func printHelp() {
        CLInterface.default.printManual()
    }
    
    /// The prefix used for short flags of `Argument`s.
    public static var prefixShortFlag = "-"
    /// The prefix used for long flags of `Argument`s.
    public static var prefixLongFlag = "--"
    
    
    // MARK: - Properties
    
    /// The name of the command line tool.
    open var name: String = ""
    /// Describes the command line tool.
    open var about: String?
    /// The version of the command line tool.
    open var version: String = "0"
    
    /// Contains the raw arguments as received from the `parse(_ rawArguments: [String])` function.
    private(set) public var rawArguments: [String]?
    /// After calling `parse()`, this property will contain any values that weren't captured by an `Option` or `Argument`.
    private(set) public lazy var unparsedArguments: [String] = []
    
    /// The underlying array of arguments.
    open var arguments: [CLConcreteArgument] = []
    /// The underlying array of arguments.
    open var options: [CLConcreteOption] = []
    
    /// Returns an array containing the short and long flags of the arguments.
    fileprivate var allPossibleArgumentNames: [String] {
        
        return arguments.filter({
            return $0.shortFlag != nil
        }).map({
            return $0.shortFlag!
        }) + arguments.map({
            return $0.longFlag
        })
    }
    
    /// The selected option parsed from the command line. May be `nil`.
    open var option: CLConcreteOption!
    /// The selected arguments parsed from the command line.
    open var selectedArguments: [CLConcreteArgument] = []
    
    /// A closure to print a custom help manual page.
    open var manualPrinter: ManualPrinter?
    
    
    // MARK: - Configuration
    
    /// The configuration set
    public var configuration: CLConfiguration = []
    
    
    // MARK: - Initialization
    
    public init(name: String, version: String = "0", about: String? = nil, configuration: CLConfiguration = []) {
        self.name = name
        self.version = version
        self.about = about
        self.configuration = configuration
        // CLInterface.default = self
    }
    
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
            printManual: CLInterface.default.configuration.contains(.printHelpOnExit))
        }
    }
    
    /// Parses the arguments from the command line given in `CommandLine.arguments` and dies with an error message.
    public static func parseOrExit() {
        CLInterface.default.parseOrExit()
    }
    
    /// Parse the given arguments.
    ///
    /// - argument arguments: The arguments to parse.
    public static func parse(_ arguments: [String]) throws {
        try CLInterface.default.parse(arguments)
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
                            print("validationResult", validationResult)
                            
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
    
    /// Prints the generated manual page for this command line tool. If the `manualPrinter` property is set it will use the output
    /// of the sepecified printer (if it's not `nil`).  Will print the default manual page generated by `CLInterface` else.
    public func printManual() {
        Swift.print(manualPrinter?(self) ?? CLInterface.defaulManualPrinter(self) ?? "No manual page.", "\n")
    }
    
    /// Prints the given message and exits the programm.
    ///
    /// - argument message:      The message to pring before exit.
    /// - argument printManual:  Boolean value indication whether to print the help page before exit.
    /// - argument exitCode:     The exit code wich will be used as a parameter for the `Foundation.exit(int)` function.
    public static func exit(_ message: String, printManual: Bool = false, exitCode: Int32 = EXIT_SUCCESS) -> Never {
        Swift.print(exitCode == EXIT_FAILURE ? "Error: \(message)\n" : "\(message)\n")
        if printManual || configuration.contains(.printHelpOnExit) { printHelp() }
        Foundation.exit(exitCode)
    }
    
    /// Print a message for the given error and exits the command line tool.
    ///
    /// - argument withError:    The error that leads to the exit of the command line tool.
    /// - argument printManual:  Boolean value indication whether to print the help page before exit.
    public static func exit(withError error: Error, printManual flag: Bool = false) -> Never {
        guard let commandLineInterfaceError = error as? CLInterfaceError else {
            exit("\(error)", printManual: flag)
        }
        
        switch commandLineInterfaceError {
        case .noOptionSelected:
            exit("No option selected.", printManual: flag || configuration.contains(.printHelpForNoSelection))
        default:
            exit(error.localizedDescription, printManual: flag)
        }
    }
}
