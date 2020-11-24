//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 24.11.20.
//

import Foundation

extension CLInterface {
    
    /// Prints the given message and exits the programm.
    ///
    /// - argument message:      The message to pring before exit.
    /// - argument printManual:  Boolean value indication whether to print the help page before exit.
    /// - argument exitCode:     The exit code wich will be used as a parameter for the `Foundation.exit(int)` function.
    public static func exit(_ message: String, printManual: Bool = false, exitCode: Int32 = EXIT_SUCCESS) -> Never {
        Swift.print(exitCode == EXIT_FAILURE ? "Error: \(message)\n" : "\(message)\n")
        if printManual || configuration.contains(.printManualOnFailure) { self.printManual() }
        Foundation.exit(exitCode)
    }
    
    /// Print a message for the given error and exits the command line tool.
    ///
    /// - argument withError:    The error that leads to the exit of the command line tool.
    /// - argument printManual:  Boolean value indication whether to print the manual page before exit.
    public static func exit(withError error: Error, printManual flag: Bool = false) -> Never {
        guard let commandLineInterfaceError = error as? CLInterfaceError else {
            CLInterface.exit("\(error)", printManual: flag)
        }
        
        switch commandLineInterfaceError {
        case .noCommandSelected:
            CLInterface.exit("No command selected.", printManual: flag || configuration.contains(.printManualOnNoSelection))
        default:
            CLInterface.exit(error.localizedDescription, printManual: flag)
        }
    }
}
