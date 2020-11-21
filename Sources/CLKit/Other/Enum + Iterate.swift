//
//  File.swift
//  
//
//  Created by Lukas Danckwerth on 31.05.20.
//

import Foundation

/// Return an iterator with all enum cases of the given enum type.
func iterateEnum<T: Hashable>(_: T?) -> AnyIterator<T> {
    var i = 0
    return AnyIterator { let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}
