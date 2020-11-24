//
//  CLConcreteArgument.swift
//  
//
//  Created by Lukas Danckwerth on 31.05.20.
//

import Foundation

open class CLConcreteArgument: CLArgumentProtocol {
    
    /// Custom closure to validate this option.String?
    open var validation: (() -> CLValidationResult)?
    
    /// Short flag of the argument. A `String` in the form of '-{FLAG_CHAR}'
    open var shortFlag: String?
    
    /// Long flag of the argument. A `String` in the form of '--{FLAG_NAME}'.
    open var longFlag: String
    
    /// A help message describing the usage of the argument.
    open var help: String?
    
    /// A Boolean value indicating whether this argument is required. Default is `false`.
    open var isRequired: Bool = false
    
    /// A Boolean value indicating whether this argument is inclued in the selected arguments.
    open var isSelected: Bool = false
    
    /// Default initialization with the given parameters.
    ///
    /// - parameter shortFlag:   The short flag of the argument. Nilable
    /// - parameter longFlag:    The long flag of the argument.
    /// - parameter help: Some help message describing the option. Nilable
    /// - parameter required:    A Boolean value indicating whether this `Argument` is required. Default is `false`.
    /// - parameter autoAdd:     A Boolean value indicating whether this `Argument` is added to the default `CommandLineInterface` on initialization.
    required public init(shortFlag: String? = nil, longFlag: String, help: String? = nil, required: Bool = false) {
        self.shortFlag = shortFlag != nil ? (shortFlag!.hasPrefix(CLInterface.prefixShortFlag) ? shortFlag : "\(CLInterface.prefixShortFlag)\(shortFlag!)") : nil
        self.longFlag = longFlag.hasPrefix(CLInterface.prefixLongFlag) ? longFlag : "\(CLInterface.prefixLongFlag)\(longFlag)"
        self.help = help
        self.isRequired = required
        CLInterface.default.arguments.append(self)
    }
    
    // MARK: - Equatable
    
    /// Returns `true` if the name of the given `Argument`s is equal.
    public static func ==(lhs: CLConcreteArgument, rhs: CLConcreteArgument) -> Bool {
        return lhs.shortFlag == rhs.shortFlag && lhs.longFlag == rhs.longFlag
    }
    
    
    // MARK: - CustomStringConvertible
    
    /// A textual representation of this instance.
    ///
    public var description: String {
        return "\(type(of: self))[\(longFlag), \(shortFlag ?? ""), isRequired: \(isRequired)]"
    }
}
