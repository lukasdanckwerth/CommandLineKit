//
//  CLFolderCommand.swift
//  
//
//  Created by Lukas Danckwerth on 14.09.20.
//

import Foundation

/// Command for Folders.
open class CLFolderCommand: CLFileCommand {
    
    /// Returns the type of the value ('FOLDER_PATH') of this argument.
    override open var valueType: String { return "FOLDER_PATH" }
    
    /// Dependant on the `isExsitenceRequired` property this function validates the existence of the file.
    override open func validate(value: URL) -> CLValidationResult {
        guard isExsitenceRequired else { return .success }
        
        var isDir : ObjCBool = false
        if FileManager.default.fileExists(atPath: value.absoluteString, isDirectory: &isDir) {
            return isDir.boolValue ? .success : .fail(message: "Expected folder but found file '\(value.absoluteString)'.")
        } else {
            return .fail(message: "Folder doesn't exist '\(value.absoluteString)'.")
        }
    }
}
