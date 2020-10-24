//
//  CLInterface + Extension.swift
//  
//
//  Created by Lukas Danckwerth on 31.05.20.
//

import Foundation
import CLKit

extension CLInterface {
    
    func getStats() -> String {
        return """
        Name: \(name)
        Configuration: \(configuration)
        
        Tokens: \(String(describing: rawArguments))
        
        Options: \(options)
        Arguments: \(arguments)
        
        Selected Option: \(String(describing: option))
        Selected Arguments: \(selectedArguments)
        """
    }
    
    static func reset() {
        CLInterface.default = CLInterface(name: "Default")
    }
}
