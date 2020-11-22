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
        
        // Satisify `OptionSet`
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
        
        /// Prints the help page in case no `Option` has been specified.  Setting this configuration lets
        /// the interface print the manual page if no option has been selected when the interface was
        /// called.
        ///
        public static let printManualOnNoSelection = CLConfiguration(rawValue: 1 << 1)
        
        /// Indicates whether a valid option is needed to be specifyed to execute.
        ///
        public static let failOnMissingOption = CLConfiguration(rawValue: 1 << 2)
        
        /// Allow unknown raw arguments.  Setting this configuration lets the interface collection unknown
        /// arguments when parsing in the `unknownArguments` collection instead of raising an exception.
        ///
        public static let allowUnknownArguments = CLConfiguration(rawValue: 1 << 3)
        
    }
}
