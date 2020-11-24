//
//  CLCommandProtocol.swift
//  
//
//  Created by Lukas Danckwerth on 31.05.20.
//

import Foundation

public protocol CLCommandProtocol: CLValidateable, Equatable, CustomStringConvertible {
    
    /// The name (and selector) of this command.
    var name: String { get set }
    
    /// Describes the effect of this command.
    var help: String? { get set }
    
    /// The collection of required arguments for this command.
    var requiredArguments: [CLConcreteArgument]? { get set }
    
    /// Default initialization with the given arguments.
    ///
    /// - argument name:  The name of the command.
    /// - argument help:  Some help message describing the command.
    init(name: String, help: String?)
    
}

extension CLCommandProtocol {
    
    // MARK: - CustomStringConvertible
    
    /// A textual representation of this instance.
    ///
    public var description: String {
        return "\(type(of: self))[name=\(name)]"
    }
}

internal extension CLCommandProtocol {
    
    var containsDefaultValue: Bool {
        guard let container = self as? CLValueContainer else { return false }
        return container.containsDefaultValue
    }
}

public typealias CLValueCommand = CLCommand & CLTypeValueContainer
