//
//  TestOptions.swift
//  CommandLineInterfaceTests
//
//  Created by Lukas Danckwerth on 17.03.18.
//  Copyright © 2018 Lukas Danckwerth. All rights reserved.
//

import XCTest
@testable import CommandLineKit

extension Float: StringInitializable {
    
    // satisfy `StringInitializable`
    public init?(string: String) {
        self.init(string)
    }
}

class TestOptions: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Reset the `CommandLineInterface`
        CommandLineInterface.default.reset()
    }
    
    

    
    enum Suboption: String {
        case suboption1
        case suboption2
    }
    
    func testOptionsParse() {
        
        for rawValue in ["-1", "0", "ab", "AB", "::"] {
            
            let stringOption = StringOption(name: "stringOption")
            
            switch stringOption.parse(rawValue: rawValue) {
            case .fail(let message): XCTFail(message)
            default: break
            }
        }
        
        
    }
    
    func testSuccessfullParsing() {
        
        CommandLineInterface.default.reset()
        
        let option = Option(name: "option")
        let stringOption = StringOption(name: "stringOption")
        let numberOption = NumberOption(name: "numberOption")
        let negNumberOption = NumberOption(name: "negNumberOption")
        let decimalOption = DecimalOption(name: "decimalOption")
        let negDecimalOption = DecimalOption(name: "negDecimalOption")
        let boolOption = BoolOption(name: "boolOption")
        let negBoolOption = BoolOption(name: "negBoolOption")
        let enumOption = EnumOption<Suboption>(name: "enumOption")
        
        CommandLineInterface.name = "TestCLT"
        
        class FloatArgument: TypedArgument<Float> { }
        
        _ = FloatArgument(shortFlag: "f", longFlag: "float", help: "Takes a float value.")
        
        guard CommandLineInterface.option != nil else {
            return
        }
        
        switch CommandLineInterface.option! {
        case option:
            print("Selected option in \(option)")
        case stringOption:
            let stringValue = stringOption.value
            print("Selected string option with value \(String(describing: stringValue))")
        case numberOption:
            let intValue = numberOption.value
            print("Selected number option with value \(String(describing: intValue))")
        default:
            fatalError() // Will not happen ...
        }
        
        do {
            try CommandLineInterface.parse(["TestCLT", "option"]) // Should succeed
            
            guard CommandLineInterface.option == option else {
                XCTFail("Selected option '\(String(describing: CommandLineInterface.option))' not like expected 'option'."); return
            }
        } catch { XCTFail(error.localizedDescription) }
        
        do {
            try CommandLineInterface.parse(["TestCLT", "stringOption", "value for string option"]) // Should succeed
            guard CommandLineInterface.option == stringOption else {
                XCTFail("Selected option '\(String(describing: CommandLineInterface.option))' not like expected 'stringOption'."); return
            }
            guard stringOption.value == "value for string option" else {
                XCTFail("Error parsing value 'stringOption'."); return
            }
        } catch { XCTFail(error.localizedDescription) }
        
        do {
            try CommandLineInterface.parse(["TestCLT", "numberOption", "123456"]) // Should succeed
            guard CommandLineInterface.option == numberOption else {
                XCTFail("Selected option '\(String(describing: CommandLineInterface.option))' not like expected 'numberOption'."); return
            }
            guard numberOption.value == 123456 else {
                XCTFail("Error parsing value 'numberOption'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
        
        do {
            try CommandLineInterface.parse(["TestCLT", "negNumberOption", "-123456"]) // Should succeed
            guard CommandLineInterface.option == negNumberOption else {
                XCTFail("Selected option '\(String(describing: CommandLineInterface.option))' not like expected 'negNumberOption'."); return
            }
            guard negNumberOption.value == -123456 else {
                XCTFail("Error parsing value 'negNumberOption'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
        
        do {
            try CommandLineInterface.parse(["TestCLT", "decimalOption", "12.3456"]) // Should succeed
            guard CommandLineInterface.option == decimalOption else {
                XCTFail("Selected option '\(String(describing: CommandLineInterface.option))' not like expected 'decimalOption'."); return
            }
            guard decimalOption.value == 12.3456 else {
                XCTFail("Error parsing value 'decimalOption'."); return
            }
        } catch { XCTFail(error.localizedDescription) }
        
        do {
            try CommandLineInterface.parse(["TestCLT", "negDecimalOption", "-12.3456"]) // Should succeed
            guard CommandLineInterface.option == negDecimalOption else {
                XCTFail("Selected option '\(String(describing: CommandLineInterface.option))' not like expected 'negDecimalOption'."); return
            }
            guard negDecimalOption.value == -12.3456 else {
                XCTFail("Error parsing value 'negDecimalOption'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
        
        do {
            try CommandLineInterface.parse(["TestCLT", "boolOption", "true"]) // Should succeed
            guard CommandLineInterface.option == boolOption else {
                XCTFail("Selected option '\(String(describing: CommandLineInterface.option))' not like expected 'boolOption'."); return
            }
            guard boolOption.value == true else {
                XCTFail("Error parsing value 'boolOption'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
        
        do {
            try CommandLineInterface.parse(["TestCLT", "negBoolOption", "false"]) // Should succeed
            guard CommandLineInterface.option == negBoolOption else {
                XCTFail("Selected option '\(String(describing: CommandLineInterface.option))' not like expected 'negBoolOption'."); return
            }
            guard negBoolOption.value == false else {
                XCTFail("Error parsing value 'negBoolOption'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
        
        do {
            try CommandLineInterface.parse(["TestCLT", "enumOption", "suboption1"]) // Should succeed
            guard CommandLineInterface.option == enumOption else {
                XCTFail("Selected option '\(String(describing: CommandLineInterface.option))' not like expected 'enumOption'."); return
            }
            guard enumOption.value == Suboption.suboption1 else {
                XCTFail("Error parsing value 'enumOption'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
        
        do {
            try CommandLineInterface.parse(["TestCLT", "enumOption", "suboption2"]) // Should succeed
            guard CommandLineInterface.option == enumOption else {
                XCTFail("Selected option '\(String(describing: CommandLineInterface.option))' not like expected 'enumOption'."); return
            }
            guard enumOption.value == Suboption.suboption2 else {
                XCTFail("Error parsing value 'enumOption'."); return
            }
        } catch let error { XCTFail(error.localizedDescription) }
    }
    
    
    // MARK: - Option Validation -
    
    func tryParse(_ args: [String], expectationToSucceed expectation: Bool) {
        
        do {
            try CommandLineInterface.parse(args)
            if !expectation { XCTFail("Parsing should have failed. \(args)") }
        } catch let error {
            if expectation { XCTFail("""
                \(CommandLineInterface.default.getStats())
                
                \(error.localizedDescription)
                """) }
        }
    }
    
    func testCustomOptionValidation() {
        
        CommandLineInterface.default.reset()
        
        let createIntOption = {
            
            CommandLineInterface.default.reset()
            
            let unpermittedValues = [1, 2, 3, 4, 5, 6]
            let intOption = NumberOption(name: "intOption", helpMessage: "Takes all int values except of [1, 2, 3, 4, 5, 6].")
            
            intOption.customValidation = {
                
                if unpermittedValues.contains(intOption.value!) {
                    return .fail(message: "Value is in unpermitted range [1, 2, 3, 4, 5, 6].")
                } else {
                    return .success
                }
            }
        }
        
        CommandLineInterface.name = "CLH-Test"
        
        createIntOption()
        tryParse(["CLH-Test", "intOption", "-1"], expectationToSucceed: true)
        createIntOption()
        tryParse(["CLH-Test", "intOption", "0"], expectationToSucceed: true)
        
        createIntOption()
        tryParse(["CLH-Test", "intOption", "1"], expectationToSucceed: false)
        createIntOption()
        tryParse(["CLH-Test", "intOption", "3"], expectationToSucceed: false)
        createIntOption()
        tryParse(["CLH-Test", "intOption", "6"], expectationToSucceed: false)
        
        createIntOption()
        tryParse(["CLH-Test", "intOption", "7"], expectationToSucceed: true)
        createIntOption()
        tryParse(["CLH-Test", "intOption", "199"], expectationToSucceed: true)
    }
    
    
    // MARK: - Options with required Arguments -
    
    func testRequiredments() {
        
        let resizeOption = StringOption(name: "resize", helpMessage: "Resizes the given image.")
        let stretchHorizontalOption = StringOption(name: "stretchHorizontal", helpMessage: "Stretches the given image horizontally.")
        
        let widthArgument = NumberArgument(shortFlag: "w", longFlag: "width", help: "The width of the output image")
        let heightArgument = NumberArgument(shortFlag: "h", longFlag: "height", help: "The height of the output image")
        
        let nameArgument = StringArgument(shortFlag: nil, longFlag: "name", help: "Specify your name.", required: true)
        
        nameArgument.isRequired = true
        
        // The resize option requires a value for both the width and the height argument
        resizeOption.requiredArguments = [widthArgument, heightArgument]
        
        // The stretch horizontal option requires a value for the width argument
        stretchHorizontalOption.requiredArguments = [widthArgument]
        
        // $ myCLT resize /Users/Bob/Desktop/Image.png
        // $ myCLT resize /Users/Bob/Desktop/Image.png -w 200
        // $ myCLT resize /Users/Bob/Desktop/Image.png -w 200 -h 200
        
        // $ myCLT stretchHorizontal /Users/Bob/Desktop/Image.png -h 400
        // $ myCLT stretchHorizontal /Users/Bob/Desktop/Image.png -w 400
    }
    
    
    func testFloatOption() {
        
        // Reset the `CommandLineInterface`
        CommandLineInterface.default = CommandLineInterface(name: "TestCLT")
        
        class NegativeFloatOption: TypedOption<Float> {
            
            override func parse(rawValue: String) -> ValidationResult {
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
        
        let negativeFloatAction = NegativeFloatOption(name: "negativeFloatAction")
        
        do {
            
            print(CommandLineInterface.default.getStats())
            try CommandLineInterface.parse(["TestCLT", "negativeFloatAction", "-12.00"]) // Should succeed
            
            guard CommandLineInterface.option == negativeFloatAction else {
                XCTFail("Selected option '\(String(describing: CommandLineInterface.option))' not like expected 'negativeFloatAction'."); return
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
            try CommandLineInterface.parse(["TestCLT", "negativeFloatAction", "12.00"]) // Should fail
            XCTFail("Parsing should fail")
            
        } catch let error {
            
            guard let error = error as? CommandLineInterface.CommandLineInterfaceError else {
                XCTFail("Error no a CommandLineInterfaceError"); return
            }
            
            switch error {
            case .parseOptionFailure(let option, _):
                XCTAssert(option == negativeFloatAction)
            default:
                XCTFail("Error not a CommandLineInterfaceError: \(error)"); return
            }
        }
    }
    
    func testEnumOption() {
        
        // Enumeration to test ...
        enum Suboption: String {
            case value1 = "value1"
            case value2 = "value2"
            case value3 = "value3"
        }
        
        // Reset the `CommandLineInterface`
        CommandLineInterface.default = CommandLineInterface(name: "CLH-Test")
        
        let enumOption = EnumOption<Suboption>(name: "suboption", helpMessage: "Choose a suboption.")
        
        var countSuccessfully = 0
        for value in ["value1", "value2", "value3"] {
            enumOption.value = nil
            do {
                try CommandLineInterface.parse(["CLH-Test", "suboption", value]) // Should pass!
                
                switch enumOption.value! {
                case .value1:
                    XCTAssert(value == "value1", "Wrong enum case parsed. Is: \(String(describing: enumOption.value)), should be: value1.")
                    countSuccessfully += 1
                    break
                case .value2:
                    XCTAssert(value == "value2", "Wrong enum case parsed. Is: \(String(describing: enumOption.value)), should be: value2.")
                    countSuccessfully += 1
                    break
                case .value3:
                    XCTAssert(value == "value3", "Wrong enum case parsed. Is: \(String(describing: enumOption.value)), should be: value3.")
                    countSuccessfully += 1
                    break
                }
                
            } catch let error {
                XCTFail(error.localizedDescription); return
            }
        }
        XCTAssert(countSuccessfully == 3)
        
        for value in ["value", "value123", "value0"] {
            enumOption.value = nil
            do {
                try CommandLineInterface.parse(["CLH-Test", "suboption", value]) // Should fail!
                XCTFail("Parsing should fail")
            } catch let error {
                guard let error = error as? CommandLineInterface.CommandLineInterfaceError else {
                    XCTFail("Error not a CommandLineInterfaceError"); return
                }
                
                switch error {
                case .parseOptionFailure(let option, _):
                    XCTAssert(option == enumOption)
                default:
                    XCTFail("Error not `.parseOptionFailure(_, _)`: \(error)"); return
                }
            }
        }
    }
    
    func testSuccessfullFileOptions() {
        
        func test(optionName: String, path: String?, fileExistenceRequired: Bool) {
            
            // Reset the `CommandLineInterface`
            CommandLineInterface.default = CommandLineInterface(name: "CLH-Test")
            
            if let path = path {
                FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
            }
            
            let option = FileOption(name: optionName, fileExistenceRequired: fileExistenceRequired)
            
            do {
                if let path = path {
                    FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
                    try CommandLineInterface.default.parse(["CLH-Test", optionName, path])
                } else {
                    try CommandLineInterface.default.parse(["CLH-Test", optionName, "/tmp/de.aid.CommandLineInterface.Tests.File Wich Existence Is Not Required"])
                }
            } catch let error {
                XCTFail(error.localizedDescription)
            }
            
            XCTAssert(path == nil || option.value?.path == path, "Failure: Wrong target path. \(String(describing: option.value?.path)), \(String(describing: path))")
        }
        
        test(optionName: "file1", path: "/tmp/de.aid.CommandLineInterface.Tests.TestFile1", fileExistenceRequired: true)
        test(optionName: "file2", path: "/tmp/de.aid.CommandLineInterface.Tests.TestFile2", fileExistenceRequired: true)
        test(optionName: "fileWithSpace1", path: "/tmp/de.aid.CommandLineInterface.Tests.Test File With Space 1", fileExistenceRequired: true)
        test(optionName: "nonExistingFile1", path: nil, fileExistenceRequired: false)
    }
    
    func testFileOptions() {
        
        var existingFileOption = FileOption(name: "file1", fileExistenceRequired: true)
        
        // Create file1...
        let path = "/tmp/de.aid.CommandLineInterfaceTestFile"
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        
        do {
            try CommandLineInterface.default.parse(["CLH-Test", "file1", path])
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        CommandLineInterface.default.reset()
        existingFileOption = FileOption(name: "file1", fileExistenceRequired: true)
        
        do {
            try CommandLineInterface.default.parse(["CLH-Test", "file1", "/tmp/invalidFilePath-jklasdAKLER2"])
            XCTFail("Parsing should fail!")
        } catch let error {
            
            guard let error = error as? CommandLineInterface.CommandLineInterfaceError else {
                XCTFail("Error no a CommandLineInterfaceError"); return
            }
            
            switch error {
            case .parseOptionFailure(let option, _):
                XCTAssert(option == existingFileOption)
            default:
                XCTFail("Unexpected Error: \(error)"); return
            }
        }
    }
}
