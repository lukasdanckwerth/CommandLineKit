//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

extension CLInterface {
    
    
    /// Typealias for a closure to print the help manual page.
    public typealias ManualPrinter = (CLInterface) -> String?
    
    /// The default printer for the manual page.
    public static var defaulManualPrinter: ManualPrinter {
        
        return { cli in
            
            func addWhitespaceIfNeeded(_ input: String) -> String {
                return input + ((input.hasSuffix(" ") || input.hasSuffix("\n") || input.hasSuffix("\t")) ? "" : " ")
            }
            
            var printMessage = "Usage: \(cli.name)"
            
            if cli.options.count > 0 { printMessage += " [option]" }
            if cli.arguments.count > 0 { printMessage += " [arguments]" }
            printMessage += "\n"
            
            if let about = cli.about {
                printMessage += "\n\(about)"
            }
            
            if cli.options.count > 0 {
                printMessage += "\n# OPTIONS:\n"
                for option in cli.options {
                    
                    printMessage += "\n\t" + option.name.bold
                    
                    if let valueableOption = option as? CLValueContainer {
                        
                        // actually very dirrty.
                        printMessage += " \(valueableOption.valueType)"
                            .replacingOccurrences(of: "Optional<", with: "")
                            .replacingOccurrences(of: ">", with: "")
                    }
                    
                    if let helpMessage = option.helpMessage {
                        printMessage += "\n\t\t\(helpMessage)"
                    }
                    
                    if let requiredArguments = option.requiredArguments {
                        printMessage = addWhitespaceIfNeeded(printMessage) + "(Requires \(requiredArguments.map({arg in arg.longFlag.bold }).joined(separator: ", ")))"
                    }
                }
                printMessage += "\n"
            }
            
            if cli.arguments.count > 0 {
                printMessage += "\n# ARGUMENTS:\n"
                for argument in cli.arguments {
                    
                    printMessage += "\n\t" + (argument.shortFlag != nil ? "\(argument.shortFlag!.bold), \(argument.longFlag.bold)" : argument.longFlag.bold)
                    
                    if let typedArgument = argument as? CLValueContainer {
                        let valueType = typedArgument.valueType
                        if valueType.contains(" ") {
                            printMessage += "   [\(typedArgument.valueType)]"
                        } else {
                            printMessage += "   \(typedArgument.valueType)"
                        }
                    }
                    
                    if let helpMessage = argument.helpMessage { printMessage += "\n\t\t\(helpMessage) " }
                    
                    if let defaultValue = (argument as? CLBaseValueContainer)?.baseDefaultValue {
                        printMessage = addWhitespaceIfNeeded(printMessage) + "(Default is '\(defaultValue)')"
                    } else if argument.isRequired {
                        printMessage = addWhitespaceIfNeeded(printMessage) + "(Required)"
                    }
                }
            }
            
            return printMessage
        }
    }
}
