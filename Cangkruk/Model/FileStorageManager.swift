//
//  FileStorageManager.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 09/07/26.
//

import Foundation

enum FileStorageManager {
    private static var directory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("TrainingFiles", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    /// Copies the file at `sourceURL` into the app's local storage and returns the stored file name.
    static func save(from sourceURL: URL) throws -> String {
        let ext = sourceURL.pathExtension
        let storedFileName = UUID().uuidString + (ext.isEmpty ? "" : ".\(ext)")
        let destinationURL = directory.appendingPathComponent(storedFileName)
        let data = try Data(contentsOf: sourceURL)
        try data.write(to: destinationURL)
        return storedFileName
    }

    static func delete(storedFileName: String) {
        let url = directory.appendingPathComponent(storedFileName)
        try? FileManager.default.removeItem(at: url)
    }

    static func url(for storedFileName: String) -> URL {
        directory.appendingPathComponent(storedFileName)
    }
}
