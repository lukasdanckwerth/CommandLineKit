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
            
            if cli.commands.count > 0 { printMessage += " [command]" }
            if cli.arguments.count > 0 { printMessage += " [arguments]" }
            printMessage += "\n"
            
            if let about = cli.about {
                printMessage += "\n\(about)"
            }
            
            if cli.commands.count > 0 {
                printMessage += "\n# OPTIONS:\n"
                for command in cli.commands {
                    
                    printMessage += "\n\t" + command.name.bold
                    
                    if let valueableCommand = command as? CLValueContainer {
                        
                        // actually very dirrty.
                        printMessage += " \(valueableCommand.valueType)"
                            .replacingOccurrences(of: "Commandal<", with: "")
                            .replacingOccurrences(of: ">", with: "")
                    }
                    
                    if let helpMessage = command.help {
                        printMessage += "\n\t\t\(helpMessage)"
                    }
                    
                    if let requiredArguments = command.requiredArguments {
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
                    
                    if let helpMessage = argument.help { printMessage += "\n\t\t\(helpMessage) " }
                    
                    if let defaultValue = (argument as? CLDefaultValueContainer)?.defaultValue {
                        printMessage = addWhitespaceIfNeeded(printMessage) + "(Default is '\(defaultValue)')"
                    } else if argument.isRequired {
                        printMessage = addWhitespaceIfNeeded(printMessage) + "(Required)"
                    }
                }
            }
            
            return printMessage
        }
    }
    
    /// Prints the generated manual page for this command line tool. If the `manualPrinter` property is set it will use the output
    /// of the sepecified printer (if it's not `nil`).  Will print the default manual page generated by `CLInterface` else.
    public func printManual() {
        Swift.print(manualPrinter?(self) ?? CLInterface.defaulManualPrinter(self) ?? "No manual page.", "\n")
    }
}
