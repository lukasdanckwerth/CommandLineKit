//
//  CLFolderArgument.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Argument which takes a path to a folder.
open class CLFolderArgument: CLFileArgument {
    
    /// Returns the type of the value ('FOLDER_PATH') of this argument.
    override open var valueType: String { return "FOLDER_PATH" }
    
    /// If `isExsitenceRequired` is set to `true` this func guards the existence of a folder a the path of the given `URL`.
    override func validate(value: URL) -> CLValidationResult {
        var isDir : ObjCBool = false
        if isExsitenceRequired && !FileManager.default.fileExists(atPath: value.absoluteString, isDirectory: &isDir) {
            return isDir.boolValue ? .success : .fail(message: "Required folder doesn't exist (\(value.absoluteString)).")
        }
        return .success
    }
}
