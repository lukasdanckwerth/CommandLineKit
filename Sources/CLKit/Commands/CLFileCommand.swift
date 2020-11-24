//
//  CLFileCommand.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

open class CLFileCommand: CLStringInitializableCommand<URL> {
    
    /// A Boolean value indicating whether the file must exists.
    open var isExsitenceRequired: Bool = false
    
    /// A Boolean value indicating whether this command translates relative to absolute paths.
    open var isTransformsRelativeToAbsolute: Bool = true
    
    /// Returns the type of the value ('FILE_PATH') of this argument.
    open var valueType: String { return "FILE_PATH" }
    
    /// Default initialization with the given arguments.
    ///
    /// - parameter name:             The name of the command.
    /// - parameter description:      Some help message describing the command.
    /// - parameter requireExistence: A Boolean value indicating whether the file must exist.
    convenience public init(name: String, help: String? = nil, fileExistenceRequired: Bool = false) {
        self.init(name: name, help: help)
        isExsitenceRequired = fileExistenceRequired
    }
    
    /// Validates the given value in raw value can be parsed to the expected type. Returns a `.fail(_)` response for an existend value
    /// or when the raw value can't be parsed.
    open override func parse(rawValue: String) -> CLValidationResult {
        var rawValue = rawValue
        guard value == nil else { return .fail(message: "Single value command '\(name)' already contains a value '\(String(describing: value))'.") }
        if isTransformsRelativeToAbsolute {
            if rawValue.hasPrefix("./") {
                rawValue.removeFirst(2)
                rawValue = "\(FileManager.default.currentDirectoryPath)/\(rawValue)"
            } else if !rawValue.hasPrefix("/") {
                rawValue = "\(FileManager.default.currentDirectoryPath)/\(rawValue)"
            }
        }
        guard let escapedPath = rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return .fail(message: "Can't add percent encoding for raw value: \(String(describing: rawValue))")
        }
        value = URL(string: escapedPath)
        guard value != nil else { return .fail(message: "Can't parse value: \(String(describing: rawValue))") }
        return validate(value: value!)
    }
    
    /// Dependant on the `isExsitenceRequired` property this function validates the existence of the file.
    open func validate(value: URL) -> CLValidationResult {
        guard isExsitenceRequired else { return .success }
        
        var isDir : ObjCBool = false
        if FileManager.default.fileExists(atPath: value.path, isDirectory: &isDir) {
            return !isDir.boolValue ? .success : .fail(message: "Expected file but found folder '\(value.absoluteString)'.")
        } else {
            return .fail(message: "File doesn't exist '\(value.path)'.")
        }
    }
}
