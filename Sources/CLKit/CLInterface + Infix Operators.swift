//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 21.11.20.
//

import Foundation

// MARK: - Option

func + (left: CLInterface, right: CLConcreteOption) -> CLInterface {
    left.options.append(right)
    return left
}

func - (left: CLInterface, right: [CLConcreteOption]) -> CLInterface {
    left.options.append(contentsOf: right)
    return left
}


// MARK: - Argument

func + (left: CLInterface, right: CLConcreteArgument) -> CLInterface {
    left.arguments.append(right)
    return left
}

func - (left: CLInterface, right: [CLConcreteArgument]) -> CLInterface {
    left.arguments.append(contentsOf: right)
    return left
}
