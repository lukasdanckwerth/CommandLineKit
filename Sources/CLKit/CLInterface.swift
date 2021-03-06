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

// ===--------------------------------------------------------------------------------------------------------------===
//
// Core (CLInterface)
// ===--------------------------------------------------------------------------------------------------------------===

open class CLInterface {
    
    // ===----------------------------------------------------------------------------------------------------------===
    //
    // MARK: - Default Instance
    // ===----------------------------------------------------------------------------------------------------------===
    
    /// Default shared instance.
    ///
    public static var `default`: CLInterface = CLInterface(name: "Default")
    
    /// The prefix used for short flags of `Argument`s.
    public static var prefixShortFlag = "-"
    
    /// The prefix used for long flags of `Argument`s.
    public static var prefixLongFlag = "--"
    
    
    // ===----------------------------------------------------------------------------------------------------------===
    //
    // MARK: - Properties
    // ===----------------------------------------------------------------------------------------------------------===
    
    /// The name of the command line tool.
    open var name: String = ""
    
    /// Describes the command line tool.
    open var about: String?
    
    /// The version of the command line tool.
    open var version: String = "0"
    

    /// The underlying array of commands.
    open var commands: [CLCommand] = []
    
    /// The underlying array of arguments.
    open var arguments: [CLConcreteArgument] = []
    

    
    /// Returns an array containing the short and long flags of the arguments.
    internal var allPossibleArgumentNames: [String] {
        
        return arguments.filter({
            return $0.shortFlag != nil
        }).map({
            return $0.shortFlag!
        }) + arguments.map({
            return $0.longFlag
        })
    }
    
    /// The selected command parsed from the command line.  May be `nil`.
    ///
    open var command: CLCommand!
    
    /// The selected arguments parsed from the command line.
    ///
    open var selectedArguments: [CLConcreteArgument] = []
    

    
    /// Contains the raw arguments as received from the `parse(_ rawArguments: [String])` function.
    internal(set) public var rawArguments: [String]?
    
    /// After calling `parse()`, this property will contain any values that weren't captured by an `Command` or `Argument`.
    internal(set) public lazy var unparsedArguments: [String] = []
    
    
    // MARK: - Configuration
    
    /// The configuration set
    public var configuration: CLConfiguration = []
    
    
    // MARK: - Manual Printer
    
    /// A closure to print a custom help manual page.
    ///
    open var manualPrinter: ManualPrinter?
    
    
    // MARK: - Initialization
    
    public init(name: String = "", version: String = "0", about: String? = nil, configuration: CLConfiguration = []) {
        self.name = name
        self.version = version
        self.about = about
        self.configuration = configuration
    }
}
