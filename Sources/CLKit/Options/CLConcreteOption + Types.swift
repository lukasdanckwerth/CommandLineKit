//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// A command line option which takes an `Int` value.
public typealias NumberOption = CLTypeOption<Int>

/// A command line option which takes an `Double` value.
public typealias DecimalOption = CLTypeOption<Double>

/// A command line option which takes an `String` value.
public typealias StringOption = CLTypeOption<String>

/// A command line option which takes an `Bool` value.
public typealias BoolOption = CLTypeOption<Bool>
