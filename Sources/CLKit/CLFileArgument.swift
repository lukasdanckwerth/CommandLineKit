//
//  CLFileArgument.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Argument which takes a path to a file.
open class CLFileArgument: URLArgument {
    
    /// A Boolean value indicating whether the file must exists.
    var isExsitenceRequired: Bool = false
    
    /// Returns the type of the value ('FILE_PATH') of this argument.
    override open var valueType: String { return "FILE_PATH" }
    
    override func parse(rawValue: String) -> CLValidationResult {
        var rawValue = rawValue
        guard internalValue == nil else { return .fail(message: "Single value argument '\(longFlag)' already contains a value '\(String(describing: value))'.") }
        if rawValue.hasPrefix("./") {
            rawValue.removeFirst(2)
            rawValue = "\(FileManager.default.currentDirectoryPath)/\(rawValue)"
        } else if !rawValue.hasPrefix("/") {
            rawValue = "\(FileManager.default.currentDirectoryPath)/\(rawValue)"
        }
        guard let escapedPath = rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return .fail(message: "Can't add percent encoding for raw value: \(String(describing: rawValue))")
        }
        internalValue = URL(fileURLWithPath: escapedPath)
        guard internalValue != nil else { return .fail(message: "Can't parse raw value: \(String(describing: rawValue))") }
        return validate(value: internalValue!)
    }
    
    /// If `isExsitenceRequired` is set to `true` this func guards the existence of a file a the path of the given `URL`.
    func validate(value: URL) -> CLValidationResult {
        if isExsitenceRequired && !FileManager.default.fileExists(atPath: value.absoluteString) {
            return .fail(message: "Required file doesn't exist (\(value.absoluteString)).")
        }
        return .success
    }
}
