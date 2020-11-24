//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Describes the configuration of a `CLInterface`.
public class CLConfiguration: OptionSet {
    
    // Satisify `CommandSet`
    //
    required public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    // The raw `Int` value of this configuration.
    //
    public let rawValue: Int
    
    /// Indicates whether to always print the help message after error messages.
    ///
    public static let printManualOnFailure = CLConfiguration(rawValue: 1)
    
    /// Prints the help page in case no `Command` has been specified.  Setting this configuration lets
    /// the interface print the manual page if no command has been selected when the interface was
    /// called.
    ///
    public static let printManualOnNoSelection = CLConfiguration(rawValue: 1 << 1)
    
    /// Indicates whether a valid command is needed to be specifyed to execute.
    ///
    public static let failOnMissingCommand = CLConfiguration(rawValue: 1 << 2)
    
    /// Allow unknown raw arguments.  Setting this configuration lets the interface collection unknown
    /// arguments when parsing in the `unknownArguments` collection instead of raising an exception.
    ///
    public static let allowUnknownArguments = CLConfiguration(rawValue: 1 << 3)
    
    
    public static var `default`: CLConfiguration {
        return [
            CLConfiguration.printManualOnFailure,
            CLConfiguration.printManualOnNoSelection,
            CLConfiguration.failOnMissingCommand,
            CLConfiguration.allowUnknownArguments,
        ]
    }
}
