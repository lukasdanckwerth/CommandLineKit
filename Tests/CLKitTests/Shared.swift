//
//  CLInterface + Extension.swift
//  
//
//  Created by Lukas Danckwerth on 31.05.20.
//

import Foundation
import XCTest

@testable
import CLKit

class CLTestCase: XCTestCase {
    
    override func setUp() {
        
        // reset the `CLInterface`
        CLInterface.reset()
    }
}

extension CLInterface {
    
    func getStats() -> String {
        return """
        Name: \(name)
        Configuration: \(configuration)
        
        Tokens: \(String(describing: rawArguments))
        
        Commands: \(commands)
        Arguments: \(arguments)
        
        Selected Command: \(String(describing: command))
        Selected Arguments: \(selectedArguments)
        """
    }
    
    static func reset() {
        CLInterface.default = CLInterface(name: "Default")
    }
}

