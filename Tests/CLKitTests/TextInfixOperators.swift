//
//  TextInfixOperators.swift
//  
//
//  Created by Lukas Danckwerth on 21.11.20.
//

import XCTest
@testable
import CLKit

class TextInfixOperators: XCTestCase {
    
    override func setUp() {
        
        // reset the `CLInterface`
        CLInterface.reset()
    }
    
    func testInfixOperators() {
        
        var interface = CLInterface()
        
        // MARK: - Options
        
        interface + CLStringOption(name: "option1", helpMessage: nil)
        interface + CLStringOption(name: "option2", helpMessage: nil)
        interface + CLStringOption(name: "option3", helpMessage: nil)
        
        XCTAssertFalse(interface.options.isEmpty, "Expecting options collection to be NOT empty.")
        XCTAssertEqual(interface.options.count, 3, "Expecting collection of options to contain 3 items.")
        
        interface = interface + [
            CLStringOption(name: "option4", helpMessage: nil),
            CLStringOption(name: "option5", helpMessage: nil)
        ]
        
        XCTAssertEqual(interface.options.count, 5, "Expecting collection of options to contain 5 items.")
        
        
        // MARK: - Arguments
        
        interface + StringArgument(longFlag: "myFlag1")
        interface + StringArgument(longFlag: "myFlag2")
        
        XCTAssertFalse(interface.arguments.isEmpty, "Expecting arguments collection to be NOT empty.")
        XCTAssertEqual(interface.arguments.count, 2, "Expecting collection of arguments to contain 2 items.")
        
        interface + [
            StringArgument(longFlag: "myFlag3"),
            StringArgument(longFlag: "myFlag4")
        ]
        
        XCTAssertEqual(interface.arguments.count, 4, "Expecting collection of arguments to contain 4 items.")
        
    }
}
