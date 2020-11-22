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
        
//        let interface = CLInterface()
//        let rawArguments: [String] = ["default", "myOption"]
//        
//        try interface.parse(rawArguments)
        
    }
}
