//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 21.11.20.
//

import Foundation

// MARK: - Command

@discardableResult
func + (left: CLInterface, right: CLCommand) -> CLInterface {
    left.commands.append(right)
    return left
}

@discardableResult
func + (left: CLInterface, right: [CLCommand]) -> CLInterface {
    left.commands.append(contentsOf: right)
    return left
}


// MARK: - Argument

@discardableResult
func + (left: CLInterface, right: CLConcreteArgument) -> CLInterface {
    left.arguments.append(right)
    return left
}

@discardableResult
func + (left: CLInterface, right: [CLConcreteArgument]) -> CLInterface {
    left.arguments.append(contentsOf: right)
    return left
}
