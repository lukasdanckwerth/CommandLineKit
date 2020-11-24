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
        
        // MARK: - Commands
        
        interface + CLStringCommand(name: "command1", help: nil)
        interface + CLStringCommand(name: "command2", help: nil)
        interface + CLStringCommand(name: "command3", help: nil)
        
        XCTAssertFalse(interface.commands.isEmpty, "Expecting commands collection to be NOT empty.")
        XCTAssertEqual(interface.commands.count, 3, "Expecting collection of commands to contain 3 items.")
        
        interface = interface + [
            CLStringCommand(name: "command4", help: nil),
            CLStringCommand(name: "command5", help: nil)
        ]
        
        XCTAssertEqual(interface.commands.count, 5, "Expecting collection of commands to contain 5 items.")
        
        
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
