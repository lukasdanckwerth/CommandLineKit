//
//  TestInterface.swift
//  
//
//  Created by Lukas Danckwerth on 22.11.20.
//

import XCTest
@testable
import CLKit

class TestInterface: XCTestCase {
    
    override func setUp() {
        
        // reset the `CLInterface`
        CLInterface.reset()
    }
    
    func testInterface() throws {
        
        let config: CLConfiguration = []
        let interface = CLInterface(name: "default", configuration: config)
        let rawArguments: [String] = ["default"]
        
        try interface.parse(rawArguments)
        
    }
}
