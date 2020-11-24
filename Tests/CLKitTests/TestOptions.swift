//
//  TestCommands.swift
//  CLInterfaceTests
//
//  Created by Lukas Danckwerth on 17.03.18.
//  Copyright © 2018 Lukas Danckwerth. All rights reserved.
//

import XCTest

@testable
import CLKit

extension Float: CLStringInitializable {
    
    // satisfy `StringInitializable`
    public init?(string: String) {
        self.init(string)
    }
}

class TestCommands: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Reset the `CLInterface`
        CLInterface.reset()
    }
    
    

    
    enum Subcommand: String {
        case subcommand1
        case subcommand2
    }
    
    func testCommandsParse() {
        
        for rawValue in ["-1", "0", "ab", "AB", "::"] {
            
            let stringCommand = CLStringCommand(name: "stringCommand")
            
            switch stringCommand.parse(rawValue: rawValue) {
            case .fail(let message): XCTFail(message)
            default: break
            }
        }
        
        
    }
    
    func testSuccessfullParsing() {
        
        CLInterface.reset()
        
        let command = CLCommand(name: "command")
        let stringCommand = CLStringCommand(name: "stringCommand")
        let numberCommand = CLNumberCommand(name: "numberCommand")
        let negCLNumberCommand = CLNumberCommand(name: "negCLNumberCommand")
        let decimalCommand = CLDecimalCommand(name: "decimalCommand")
        let negCLDecimalCommand = CLDecimalCommand(name: "negCLDecimalCommand")
        let boolCommand = CLBoolCommand(name: "boolCommand")
        let negCLBoolCommand = CLBoolCommand(name: "negCLBoolCommand")
        let enumCommand = CLEnumCommand<Subcommand>(name: "enumCommand")
        
        CLInterface.name = "TestCLT"
        
        class FloatArgument: CLStringInitializableArgument<Float> { }
        
        _ = FloatArgument(shortFlag: "f", longFlag: "float", help: "Takes a float value.")
        
        guard CLInterface.command != nil else {
            return
        }
        
        switch CLInterface.command! {
        case command:
            print("Selected command in \(command)")
        case stringCommand:
            let stringValue = stringCommand.value
            print("Selected string command with value \(String(describing: stringValue))")
        case numberCommand:
            let intValue = numberCommand.value
            print("Selected number command with value \(String(describing: intValue))")
        default:
            fatalError() // Will not happen ...
        }
        
        do {
            try CLInterface.parse(["TestCLT", "command"]) // Should succeed
            
            guard CLInterface.command == command else {
                XCTFail("Selected command '\(String(describing: CLInterface.command))' not like expected 'command'."); return
            }
        } catch { XCTFail(error.localizedDescription) }
        
        do {
            try CLInterface.parse(["TestCLT", "stringCommand", "value for string command"]) // Should succeed
            guard CLInterface.command == stringCommand else {
                XCTFail("Selected command '\(String(describing: CLInterface.command))' not like expected 'stringCommand'."); return
            }
            guard stringCommand.value == "value for string command" else {
                XCTFail("Error parsing value 'stringCommand'."); return
            }
        } catch { XCTFail(error.localizedDescription) }
        
        do {
            try CLInterface.parse(["TestCLT", "numberCommand", "123456"]) // Should succeed
            guard CLInterface.command == numberCommand else {
                XCTFail("Selected command '\(String(describing: CLInterface.command))' not like expected 'numberCommand'."); return
            }
            guard numberCommand.value == 123456 else {
                XCTFail("Error parsing value 'numberCommand'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
        
        do {
            try CLInterface.parse(["TestCLT", "negCLNumberCommand", "-123456"]) // Should succeed
            guard CLInterface.command == negCLNumberCommand else {
                XCTFail("Selected command '\(String(describing: CLInterface.command))' not like expected 'negCLNumberCommand'."); return
            }
            guard negCLNumberCommand.value == -123456 else {
                XCTFail("Error parsing value 'negCLNumberCommand'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
        
        do {
            try CLInterface.parse(["TestCLT", "decimalCommand", "12.3456"]) // Should succeed
            guard CLInterface.command == decimalCommand else {
                XCTFail("Selected command '\(String(describing: CLInterface.command))' not like expected 'decimalCommand'."); return
            }
            guard decimalCommand.value == 12.3456 else {
                XCTFail("Error parsing value 'decimalCommand'."); return
            }
        } catch { XCTFail(error.localizedDescription) }
        
        do {
            try CLInterface.parse(["TestCLT", "negCLDecimalCommand", "-12.3456"]) // Should succeed
            guard CLInterface.command == negCLDecimalCommand else {
                XCTFail("Selected command '\(String(describing: CLInterface.command))' not like expected 'negCLDecimalCommand'."); return
            }
            guard negCLDecimalCommand.value == -12.3456 else {
                XCTFail("Error parsing value 'negCLDecimalCommand'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
        
        do {
            try CLInterface.parse(["TestCLT", "boolCommand", "true"]) // Should succeed
            guard CLInterface.command == boolCommand else {
                XCTFail("Selected command '\(String(describing: CLInterface.command))' not like expected 'boolCommand'."); return
            }
            guard boolCommand.value == true else {
                XCTFail("Error parsing value 'boolCommand'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
        
        do {
            try CLInterface.parse(["TestCLT", "negCLBoolCommand", "false"]) // Should succeed
            guard CLInterface.command == negCLBoolCommand else {
                XCTFail("Selected command '\(String(describing: CLInterface.command))' not like expected 'negCLBoolCommand'."); return
            }
            guard negCLBoolCommand.value == false else {
                XCTFail("Error parsing value 'negCLBoolCommand'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
        
        do {
            try CLInterface.parse(["TestCLT", "enumCommand", "subcommand1"]) // Should succeed
            guard CLInterface.command == enumCommand else {
                XCTFail("Selected command '\(String(describing: CLInterface.command))' not like expected 'enumCommand'."); return
            }
            guard enumCommand.value == Subcommand.subcommand1 else {
                XCTFail("Error parsing value 'enumCommand'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
        
        do {
            try CLInterface.parse(["TestCLT", "enumCommand", "subcommand2"]) // Should succeed
            guard CLInterface.command == enumCommand else {
                XCTFail("Selected command '\(String(describing: CLInterface.command))' not like expected 'enumCommand'."); return
            }
            guard enumCommand.value == Subcommand.subcommand2 else {
                XCTFail("Error parsing value 'enumCommand'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
    }
    
    
    // MARK: - Command Validation -
    
    func tryParse(_ args: [String], expectationToSucceed expectation: Bool) {
        
        do {
            try CLInterface.parse(args)
            if !expectation { XCTFail("Parsing should have failed. \(args)") }
        } catch let error {
            if expectation { XCTFail("""
                \(CLInterface.default.getStats())
                
                \(error.localizedDescription)
                """) }
        }
    }
    
    func testCustomCommandValidation() {
        
        CLInterface.reset()
        
        let createIntCommand = {
            
            CLInterface.reset()
            
            let unpermittedValues = [1, 2, 3, 4, 5, 6]
            let intCommand = CLNumberCommand(name: "intCommand", help: "Takes all int values except of [1, 2, 3, 4, 5, 6].")
            
            intCommand.validation = {
                
                if unpermittedValues.contains(intCommand.value!) {
                    return .fail(message: "Value is in unpermitted range [1, 2, 3, 4, 5, 6].")
                } else {
                    return .success
                }
            }
        }
        
        CLInterface.name = "CLH-Test"
        
        createIntCommand()
        tryParse(["CLH-Test", "intCommand", "-1"], expectationToSucceed: true)
        createIntCommand()
        tryParse(["CLH-Test", "intCommand", "0"], expectationToSucceed: true)
        
        createIntCommand()
        tryParse(["CLH-Test", "intCommand", "1"], expectationToSucceed: false)
        createIntCommand()
        tryParse(["CLH-Test", "intCommand", "3"], expectationToSucceed: false)
        createIntCommand()
        tryParse(["CLH-Test", "intCommand", "6"], expectationToSucceed: false)
        
        createIntCommand()
        tryParse(["CLH-Test", "intCommand", "7"], expectationToSucceed: true)
        createIntCommand()
        tryParse(["CLH-Test", "intCommand", "199"], expectationToSucceed: true)
    }
    
    
    // MARK: - Commands with required Arguments -
    
    func testRequirements() {
        
        let resizeCommand = CLStringCommand(name: "resize", help: "Resizes the given image.")
        let stretchHorizontalCommand = CLStringCommand(name: "stretchHorizontal", help: "Stretches the given image horizontally.")
        
        let widthArgument = NumberArgument(shortFlag: "w", longFlag: "width", help: "The width of the output image")
        let heightArgument = NumberArgument(shortFlag: "h", longFlag: "height", help: "The height of the output image")
        
        let nameArgument = StringArgument(shortFlag: nil, longFlag: "name", help: "Specify your name.", required: true)
        
        nameArgument.isRequired = true
        
        // The resize command requires a value for both the width and the height argument
        resizeCommand.requiredArguments = [widthArgument, heightArgument]
        
        // The stretch horizontal command requires a value for the width argument
        stretchHorizontalCommand.requiredArguments = [widthArgument]
        
        // $ myCLT resize /Users/Bob/Desktop/Image.png
        // $ myCLT resize /Users/Bob/Desktop/Image.png -w 200
        // $ myCLT resize /Users/Bob/Desktop/Image.png -w 200 -h 200
        
        // $ myCLT stretchHorizontal /Users/Bob/Desktop/Image.png -h 400
        // $ myCLT stretchHorizontal /Users/Bob/Desktop/Image.png -w 400
    }
    
    
    func testFloatCommand() {
        
        // Reset the `CLInterface`
        CLInterface.default = CLInterface(name: "TestCLT")
        
        class NegativeFloatCommand: CLStringInitializableCommand<Float> {
            
            override func parse(rawValue: String) -> CLValidationResult {
                guard let float = Float(string: rawValue) else {
                    return .fail(message: "Can't parse raw value '\(rawValue)' to expected type Float.")
                }
                
                if float < 0 {
                    self.value = float
                    return .success
                } else {
                    return .fail(message: "Value '\(float)' not negative.")
                }
            }
        }
        
        let negativeFloatAction = NegativeFloatCommand(name: "negativeFloatAction")
        
        do {
            
            print(CLInterface.default.getStats())
            try CLInterface.parse(["TestCLT", "negativeFloatAction", "-12.00"]) // Should succeed
            
            guard CLInterface.command == negativeFloatAction else {
                XCTFail("Selected command '\(String(describing: CLInterface.command))' not like expected 'negativeFloatAction'."); return
            }
            
            guard negativeFloatAction.value == -12.00 else {
                XCTFail("Error parsing value 'negativeFloatAction'."); return
            }
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // Reset
        negativeFloatAction.value = nil
        
        do {
            try CLInterface.parse(["TestCLT", "negativeFloatAction", "12.00"]) // Should fail
            XCTFail("Parsing should fail")
            
        } catch let error {
            
            guard let error = error as? CLInterfaceError else {
                XCTFail("Error no a CLInterfaceError"); return
            }
            
            switch error {
            case .parseCommandFailure(let command, _):
                XCTAssert(command == negativeFloatAction)
            default:
                XCTFail("Error not a CLInterfaceError: \(error)"); return
            }
        }
    }
    
    func testEnumCommand() {
        
        // Enumeration to test ...
        enum Subcommand: String {
            case value1 = "value1"
            case value2 = "value2"
            case value3 = "value3"
        }
        
        // Reset the `CLInterface`
        CLInterface.default = CLInterface(name: "CLH-Test")
        
        let enumCommand = CLEnumCommand<Subcommand>(name: "subcommand", help: "Choose a subcommand.")
        
        var countSuccessfully = 0
        for value in ["value1", "value2", "value3"] {
            enumCommand.value = nil
            do {
                try CLInterface.parse(["CLH-Test", "subcommand", value]) // Should pass!
                
                switch enumCommand.value! {
                case .value1:
                    XCTAssert(value == "value1", "Wrong enum case parsed. Is: \(String(describing: enumCommand.value)), should be: value1.")
                    countSuccessfully += 1
                    break
                case .value2:
                    XCTAssert(value == "value2", "Wrong enum case parsed. Is: \(String(describing: enumCommand.value)), should be: value2.")
                    countSuccessfully += 1
                    break
                case .value3:
                    XCTAssert(value == "value3", "Wrong enum case parsed. Is: \(String(describing: enumCommand.value)), should be: value3.")
                    countSuccessfully += 1
                    break
                }
                
            } catch CLInterfaceError.unknownArgument(let rawArgument) {
                print(CLInterface.default.getStats())
                print("unknownArgument: \(rawArgument)")
            } catch {
                print(CLInterface.default.getStats())
                print("error: \(error)")
                XCTFail(error.localizedDescription); return
            }
        }
        XCTAssert(countSuccessfully == 3)
        
        for value in ["value", "value123", "value0"] {
            enumCommand.value = nil
            do {
                try CLInterface.parse(["CLH-Test", "subcommand", value]) // Should fail!
                XCTFail("Parsing should fail")
            } catch let error {
                guard let error = error as? CLInterfaceError else {
                    XCTFail("Error not a CLInterfaceError"); return
                }
                
                switch error {
                case .parseCommandFailure(let command, _):
                    XCTAssert(command == enumCommand)
                default:
                    XCTFail("Error not `.parseCommandFailure(_, _)`: \(error)"); return
                }
            }
        }
    }
    
    func testSuccessfullFileCommands() {
        
        func test(commandName: String, path: String?, fileExistenceRequired: Bool) {
            
            // Reset the `CLInterface`
            CLInterface.default = CLInterface(name: "CLH-Test")
            
            if let path = path {
                FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
            }
            
            let command = CLFileCommand(name: commandName, fileExistenceRequired: fileExistenceRequired)
            
            do {
                if let path = path {
                    FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
                    try CLInterface.default.parse(["CLH-Test", commandName, path])
                } else {
                    try CLInterface.default.parse(["CLH-Test", commandName, "/tmp/de.aid.CLInterface.Tests.File Wich Existence Is Not Required"])
                }
            } catch let error {
                XCTFail(error.localizedDescription)
            }
            
            XCTAssert(path == nil || command.value?.path == path, "Failure: Wrong target path. \(String(describing: command.value?.path)), \(String(describing: path))")
        }
        
        test(commandName: "file1", path: "/tmp/de.aid.CLInterface.Tests.TestFile1", fileExistenceRequired: true)
        test(commandName: "file2", path: "/tmp/de.aid.CLInterface.Tests.TestFile2", fileExistenceRequired: true)
        test(commandName: "fileWithSpace1", path: "/tmp/de.aid.CLInterface.Tests.Test File With Space 1", fileExistenceRequired: true)
        test(commandName: "nonExistingFile1", path: nil, fileExistenceRequired: false)
    }
    
    func testFileCommands() {
        
        var existingFileCommand = CLFileCommand(name: "file1", fileExistenceRequired: true)
        
        // Create file1...
        let path = "/tmp/de.aid.CLInterfaceTestFile"
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        
        do {
            try CLInterface.default.parse(["CLH-Test", "file1", path])
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        CLInterface.reset()
        existingFileCommand = CLFileCommand(name: "file1", fileExistenceRequired: true)
        
        do {
            try CLInterface.default.parse(["CLH-Test", "file1", "/tmp/invalidFilePath-jklasdAKLER2"])
            XCTFail("Parsing should fail!")
        } catch let error {
            
            guard let error = error as? CLInterfaceError else {
                XCTFail("Error no a CLInterfaceError"); return
            }
            
            switch error {
            case .parseCommandFailure(let command, _):
                XCTAssert(command == existingFileCommand)
            default:
                XCTFail("Unexpected Error: \(error)"); return
            }
        }
    }
}
