//
//  TestArguments.swift
//  CommandLineKitTests
//
//  Created by Lukas Danckwerth on 18.06.19.
//  Copyright © 2019 Lukas Danckwerth. All rights reserved.
//

import XCTest
@testable import CommandLineKit


class TestArguments: XCTestCase {

    override func setUp() {
        
        // Reset the `CommandLineInterface`
        CommandLineInterface.default.reset()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    
    func testDefaultValues() {
        
        CommandLineInterface.default.reset()
        
        let numberArgumentDefault0 = NumberArgument(shortFlag: "n1", longFlag: "number1", defaultValue: 0)
        let numberArgumentDefault1 = NumberArgument(shortFlag: "n2", longFlag: "number2", defaultValue: 1)
        let numberArgumentDefaultMinus1 = NumberArgument(shortFlag: "n3", longFlag: "number3", defaultValue: -1)
        let numberArgument = NumberArgument(shortFlag: "n4", longFlag: "number4")
        
        let stringArgumentDefaultCow = StringArgument(longFlag: "animal", defaultValue: "Cow")
        
        do {
            try CommandLineInterface.parse(["CLH-Test", "-n1", "2", "-n4", "100", "--animal", "Pig"])
        } catch let error {
            XCTFail("""
                \(CommandLineInterface.string(from: error))
                \(CommandLineInterface.default.getStats())
                """)
        }
        
        XCTAssert(numberArgumentDefault0.value == 2, "Value of argument not as expected \(numberArgumentDefault0).")
        XCTAssert(numberArgumentDefault1.value == 1, "Argument did not return default value \(numberArgumentDefault1).")
        XCTAssert(numberArgumentDefaultMinus1.value == -1, "Argument did not return default value \(numberArgumentDefaultMinus1).")
        XCTAssert(numberArgument.value == 100, "Value of argument not as expected \(numberArgument).")
        
        XCTAssert(stringArgumentDefaultCow.value == "Pig", "Value of argument not as expected \(stringArgumentDefaultCow).")
    }
}
