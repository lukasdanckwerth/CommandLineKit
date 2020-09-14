//
//  CLStringInitializable + Types.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

extension Int: CLStringInitializable { }

extension Double: CLStringInitializable { }

extension Bool: CLStringInitializable { }

extension String: CLStringInitializable { }

extension URL: CLStringInitializable {
    
    public init?(_ string: String) {
        self.init(string: string)
    }
}
