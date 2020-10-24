//
//  TestConfiguation.swift
//  CLInterfaceTests
//
//  Created by Lukas Danckwerth on 31.03.18.
//  Copyright © 2018 Lukas Danckwerth. All rights reserved.
//

import XCTest
@testable
import CLKit

class TestConfiguation: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMultiArgumentsInSingleDefinition() {
        
        for argument in ["-b", "-abcde"] {
            
            CLInterface.reset()
            CLInterface.default.name = "CMT-Test"
            
            let argument1 = CLConcreteArgument(shortFlag: "a", longFlag: "argumentA")
            let argument2 = CLConcreteArgument(shortFlag: "b", longFlag: "argumentB")
            let argument3 = CLConcreteArgument(shortFlag: "c", longFlag: "argumentC")
            let argument4 = CLConcreteArgument(shortFlag: "d", longFlag: "argumentD")
            let argument5 = CLConcreteArgument(shortFlag: "e", longFlag: "argumentE")
            
            let intArgument = NumberArgument(shortFlag: "n", longFlag: "number")
            
            do {
                try CLInterface.default.parse(["CMT-Test", argument, "-n", "10"])
                
                if argument.contains("a") {
                    XCTAssert(argument1.isSelected)
                }
                
                if argument.contains("b") {
                    XCTAssert(argument2.isSelected)
                }
                
                if argument.contains("c") {
                    XCTAssert(argument3.isSelected)
                }
                
                if argument.contains("d") {
                    XCTAssert(argument4.isSelected)
                }
                
                if argument.contains("e") {
                    XCTAssert(argument5.isSelected)
                }
                
                XCTAssert(intArgument.value == 10)
                
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testInfixOperators() {
        
    }
    
    // TODO: Wrong test due to non existing single option mode (for now).
    func testSingleOptionMode() {
        
    }
}
