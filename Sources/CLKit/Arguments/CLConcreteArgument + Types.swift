//
//  CLConcreteArgument + Types.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Typealias for arguments whith a `String` value.
public typealias CLStringArgument = CLStringInitializableArgument<String>

/// Typealias for arguments whith an `Int` value.
public typealias CLNumberArgument = CLStringInitializableArgument<Int>

/// Typealias for arguments whith a `Double` value.
public typealias CLDecimalArgument = CLStringInitializableArgument<Double>

/// Typealias for arguments whith a `URL` value.
public typealias CLURLArgument = CLStringInitializableArgument<URL>
