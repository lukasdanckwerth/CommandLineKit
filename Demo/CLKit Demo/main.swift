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

let helloOption = StringOption(name: "hello", helpMessage: "prints a welcome message")
let helloOption2 = StringOption(name: "hello", helpMessage: "prints a welcome message")
demoTool.options = [helloOption, helloOption2]

demoTool.printHelp()
demoTool.parseOrExit()
