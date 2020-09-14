//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

extension String {
    
    /// Returns this string in a form which will be printed as bold in the terminal.
    var bold: String {
        return "\u{001B}[1m\(self)\u{001B}[0m"
    }
}
