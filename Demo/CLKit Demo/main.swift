//
//  main.swift
//  CommandLineKit Demo
//
//  Created by Lukas Danckwerth on 14.09.20.
//  Copyright © 2020 Anika. All rights reserved.
//

import Foundation
import CLKit

let demoTool = CLInterface(
    name: "demo",
    version: "1.0.0",
    about: "Some cool about text",
    configuration: .printHelpForNoSelection
)

let helloCommand = CLStringCommand(name: "hello", helpMessage: "prints a welcome message")
let helloCommand2 = CLStringCommand(name: "hello", helpMessage: "prints a welcome message")
demoTool.commands = [helloCommand, helloCommand2]

demoTool.printHelp()
demoTool.parseOrExit()
