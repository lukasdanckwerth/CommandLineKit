//
//  CLStringInitializable.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Protocol that can be implemented by types you want to parse from the command line.
///
public protocol CLStringInitializable {
    
    /// Initializes this value from the given string argument.
    ///
    init?(_ string: String)
    
}

/// Make `int` suitable to the `CLStringInitializable` protocol.
///
extension Int: CLStringInitializable { }

/// Make `Double` suitable to the `CLStringInitializable` protocol.
///
extension Double: CLStringInitializable { }

/// Make `Bool` suitable to the `CLStringInitializable` protocol.
///
extension Bool: CLStringInitializable { }

/// Make `String` suitable to the `CLStringInitializable` protocol.
///
extension String: CLStringInitializable { }

/// Make `URL` suitable to the `CLStringInitializable` protocol.
///
extension URL: CLStringInitializable {
    
    public init?(_ string: String) {
        self.init(string: string)
    }
}
