//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

extension CLInterface {
    
    /// Describes the configuration of a `CLInterface`.
    public class CLConfiguration: OptionSet {
        
        required public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// The raw `Int` value of this configuration.
        public let rawValue: Int
        
        /// Indicates whether to always print the help message after error messages
        public static let printHelpOnExit = CLConfiguration(rawValue: 1)
        
        /// Indicates whether a valid option is needed to be specifyed to execute.rawValue
        public static let failOnMissingOption = CLConfiguration(rawValue: 1 << 1)
        
        /// Prints the help page in case no `Option` has been specified
        public static let printHelpForNoSelection = CLConfiguration(rawValue: 1 << 3)
        
        /// Allow unknown raw arguments
        public static let allowUnknownArguments = CLConfiguration(rawValue: 1 << 4)
    }
}
