//
//  Logger.swift
//  SentryTools
//
//  Created by Michael Eid on 8/1/25.
//

import Foundation

public enum LoggerError: Error, LocalizedError {
    case encodingFailed
    case fileAccessDenied
    case diskSpaceFull

    public var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode log message to UTF-8"
        case .fileAccessDenied:
            return "Access denied to log file"
        case .diskSpaceFull:
            return "Insufficient disk space for logging"
        }
    }
}

public class Logger {
    public static let filePath: String = {
        let manager = FileManager.default
        let urls = manager.urls(for: .documentDirectory, in: .userDomainMask)
        let logURL = urls[0].appendingPathComponent("app.log")
        return logURL.path
    }()

    static func log(_ message: String, type: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        let logMessage = "\(timestamp): \(message)\n"
        print(logMessage)

        do {
            try appendToFile(logMessage)
        } catch {
            print("Logger Error: Failed to write to log file - \(error)")
        }
    }

    static func appendToFile(_ message: String) throws {
        guard let data = message.data(using: String.Encoding.utf8) else {
            throw LoggerError.encodingFailed
        }

        if FileManager.default.fileExists(atPath: filePath) {
            do {
                let fileSize = try Self.getFileSize()
                if fileSize > maxFileLogSize {
                    print("Logger: File size (\(fileSize) bytes) exceeds limit, forcing truncation...")
                    try FileManager.default.removeItem(atPath: filePath)
                    print("Logger: Log file deleted successfully")
                }
            } catch {
                print("Logger: Warning - could not check file size: \(error)")
            }
        }

        if FileManager.default.fileExists(atPath: filePath) {
            let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: filePath))
            defer { fileHandle.closeFile() }

            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        } else {
            try data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
        }
    }

    public static func clearLogs() {
        do {
            if FileManager.default.fileExists(atPath: filePath) {
                let emptyData = Data()
                try emptyData.write(to: URL(fileURLWithPath: filePath), options: .atomic)
            } else {
                FileManager.default.createFile(atPath: filePath, contents: nil)
            }
        } catch {
            Self.error("Error clearing log file: \(error)")
        }
    }

    public static func debug(_ message: String) {
        log(message, type: "DEBUG")
    }

    public static func info(_ message: String) {
        log(message, type: "INFO")
    }

    public static func warning(_ message: String) {
        log(message, type: "WARNING")
    }

    public static func error(_ message: String) {
        log(message, type: "ERROR")
    }

    public static func getLogFileDiagnostics() -> String {
        let fileManager = FileManager.default
        var diagnostics = ["=== Logger Diagnostics ==="]

        diagnostics.append("File Path: \(filePath)")
        diagnostics.append("File Exists: \(fileManager.fileExists(atPath: filePath))")

        if fileManager.fileExists(atPath: filePath) {
            do {
                let attributes = try fileManager.attributesOfItem(atPath: filePath)
                let fileSize = attributes[.size] as? NSNumber ?? 0
                let permissions = attributes[.posixPermissions] as? NSNumber ?? 0
                let modDate = attributes[.modificationDate] as? Date

                diagnostics.append("File Size: \(fileSize) bytes")
                diagnostics.append("Permissions: \(String(format: "%o", permissions.uint16Value))")
                diagnostics.append("Last Modified: \(modDate?.description ?? "Unknown")")

                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                if let content = String(data: data, encoding: .utf8) {
                    let lines = content.components(separatedBy: .newlines)
                    diagnostics.append("Total Lines: \(lines.count)")
                    diagnostics.append("First Line: \(lines.first ?? "Empty")")
                }

            } catch {
                diagnostics.append("Error reading file info: \(error)")
            }
        }

        return diagnostics.joined(separator: "\n")
    }

    private static func getFileSize() throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
        return (attributes[.size] as? NSNumber)?.int64Value ?? 0
    }

    static let maxFileLogSize = 50_000_000
}
