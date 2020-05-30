//
//  TestArgumentsInvalidValues.swift
//  CommandLineKitTests
//
//  Created by Lukas Danckwerth on 18.06.19.
//  Copyright © 2019 Lukas Danckwerth. All rights reserved.
//

import XCTest
@testable import CommandLineKit

class TestArgumentsInvalidValues: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Reset the `CommandLineInterface`
        CommandLineInterface.default.reset()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNoValueParsedError() {
        
        for args in [["CLH-Test", "-s"],
                     ["CLH-Test", "--string"],
                     ["CLH-Test", "-n", "12", "-s"],
                     ["CLH-Test", "-n", "12", "--string"],
                     ["CLH-Test", "-s", "-n", "12"],
                     ["CLH-Test", "--string", "-n", "12"]
            ] {
                
                CommandLineInterface.default.reset()
                let _ = NumberArgument(shortFlag: "n", longFlag: "number", help: "")
                let stringArgument = StringArgument(shortFlag: "s", longFlag: "string", help: "")
                wrapTryCatchForNoValueParsedError(args: args, argumentWithMissingValue: stringArgument)
                
        }
        
        for args in [["CLH-Test", "-n"],
                     ["CLH-Test", "--number"]
            ] {
                
                CommandLineInterface.default.reset()
                let numberArgument = NumberArgument(shortFlag: "n", longFlag: "number", help: "")
                wrapTryCatchForNoValueParsedError(args: args, argumentWithMissingValue: numberArgument)
                
        }
        
        for args in [["CLH-Test", "-d"],
                     ["CLH-Test", "--decimal"]
            ] {
                
                CommandLineInterface.default.reset()
                let decimalArgument = StringArgument(shortFlag: "d", longFlag: "decimal")
                wrapTryCatchForNoValueParsedError(args: args, argumentWithMissingValue: decimalArgument)
                
        }
        
    }
    
    func wrapTryCatchForNoValueParsedError<Type>(args: [String], argumentWithMissingValue: TypedArgument<Type>) {
        do {
            try CommandLineInterface.parse(args) // Should fail!
            XCTFail("""
                Parsing should fail
                
                \(CommandLineInterface.default.getStats())
                """)
        } catch let error {
            
            guard let error = error as? CommandLineInterface.CommandLineInterfaceError else {
                XCTFail("Error not a CommandLineInterfaceError"); return
            }
            
            switch error {
            case CommandLineInterface.CommandLineInterfaceError.missingRequiredArgumentValue(let argument):
                XCTAssert(argument == argumentWithMissingValue)
            default:
                XCTFail("""
                    Error not `.noValueParsed(_)`. Is: \(error)
                    
                    \(CommandLineInterface.default.getStats())
                    """); return
            }
        }
    }
    
    func testNoValidValueError() {
        
        for invalidArgument in ["NoNumericString", "10.0", "-10.0", "true", "false", ""] {
            
            CommandLineInterface.default.reset()
            let numberArgument = NumberArgument(shortFlag: "n", longFlag: "number", help: "")
            
            wrapTryCatchForNoValidValueError(args: ["CLH-Test", "--number", invalidArgument], argumentWithInvalidValue: numberArgument)
        }
        
        for invalidArgument in ["NoNumericString", "true", "false", ""] {
            
            CommandLineInterface.default.reset()
            let decimalArgument = DecimalArgument(shortFlag: "d", longFlag: "decimal")
            
            wrapTryCatchForNoValidValueError(args: ["CLH-Test", "--decimal", invalidArgument], argumentWithInvalidValue: decimalArgument)
        }
    }
    
    func wrapTryCatchForNoValidValueError<Type>(args: [String], argumentWithInvalidValue: TypedArgument<Type>) {
        do {
            try CommandLineInterface.parse(args) // Should fail!
            XCTFail("Parsing value \(String(describing: argumentWithInvalidValue.value)) for \(argumentWithInvalidValue) should fail")
        } catch let error {
            
            guard let error = error as? CommandLineInterface.CommandLineInterfaceError else {
                XCTFail("Error not a CommandLineInterfaceError"); return
            }
            
            switch error {
            case CommandLineInterface.CommandLineInterfaceError.missingRequiredArgumentValue(let argument):
                XCTAssert(argument == argumentWithInvalidValue)
            case CommandLineInterface.CommandLineInterfaceError.parseArgumentFailure(let argument, let message):
                print(message)
                XCTAssert(argument == argumentWithInvalidValue)
            default:
                XCTFail("Error not `.noValidValue(_)`. Is: \(error)"); return
            }
        }
    }
}
