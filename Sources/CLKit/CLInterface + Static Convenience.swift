//
//  CLInterface + Static Convenience.swift
//  
//
//  Created by Lukas Danckwerth on 15.09.20.
//

import Foundation

extension CLInterface {
    
    /// The program's current directory path.
    public static var currentDirectoryPath: String {
        return FileManager.default.currentDirectoryPath
    }
    
    /// The program's current directory `URL`.
    public static var currentDirectoryURL: URL {
        return URL(fileURLWithPath: currentDirectoryPath)
    }
    
    // MARK: - Properties
    
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
    
    /// The defaults interface configuration.
    public static var configuration: CLConfiguration {
        get { return CLInterface.default.configuration }
        set { CLInterface.default.configuration = newValue }
    }
    
    // MARK: - Parse
    
    /// Prints the generated help page for this command line tool.
    public static func printHelp() {
        CLInterface.default.printHelp()
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
}
