//
//  Logger.swift
//  Protocols
//
//  Adapted by Cassio Rossi on 14/03/2019.
//  Copyright © 2019 Cassio Rossi. All rights reserved.
//

import Foundation
import os.log

class Log {

    /// Enum which maps an appropiate symbol which added as prefix for each log message
    ///
    /// - error: Log type error
    /// - info: Log type info
    /// - debug: Log type debug
    /// - verbose: Log type verbose
    /// - warning: Log type warning
    /// - severe: Log type severe
    enum LogEvent: String {
        case error = "[‼️]" // error
        case info = "[ℹ️]" // info
        case debug = "[💬]" // debug
        case warning = "[⚠️]" // warning
    }

    static var dateFormat = "yyyy-MM-dd HH:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }

    private static var isLoggingEnabled: Bool {
        return true
    }

    // MARK: - Logging methods -

    /// Logs error messages on console with prefix [‼️]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    fileprivate class func error( _ object: Any?,
                                  filename: String = #file,
                                  line: Int = #line,
                                  column: Int = #column,
                                  funcName: String = #function) {
        showLog(object, filename: filename, line: line, method: funcName, event: LogEvent.error)
    }

    /// Logs info messages on console with prefix [ℹ️]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    fileprivate class func info( _ object: Any?,
                                 filename: String = #file,
                                 line: Int = #line,
                                 column: Int = #column,
                                 funcName: String = #function) {
        showLog(object, filename: filename, line: line, method: funcName, event: LogEvent.info)
    }

    /// Logs debug messages on console with prefix [💬]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    fileprivate class func debug( _ object: Any?,
                                  filename: String = #file,
                                  line: Int = #line,
                                  column: Int = #column,
                                  funcName: String = #function) {
        showLog("\n\t==> \(object ?? "")", filename: filename, line: line, method: funcName, event: LogEvent.debug)
    }

    /// Logs warnings verbosely on console with prefix [⚠️]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    fileprivate class func warning( _ object: Any?,
                                    filename: String = #file,
                                    line: Int = #line,
                                    column: Int = #column,
                                    funcName: String = #function) {
        showLog(object, filename: filename, line: line, method: funcName, event: LogEvent.warning)
    }

    /// Extract the file name from the file path
    ///
    /// - Parameter filePath: Full file path in bundle
    /// - Returns: File Name with extension
    fileprivate class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        if components.isEmpty {
            return ""
        }
        guard let last = components.last else {
            return ""
        }
        return last
    }

    fileprivate class func showLog(_ object: Any?,
                                   filename: String,
                                   line: Int,
                                   method: String,
                                   event: LogEvent) {
        if isLoggingEnabled {
            let message = "\(Date().toString()) \(event.rawValue) [\(sourceFileName(filePath: filename))]: line \(line) | method: \(method) -> \(object ?? "")"

            guard let bundle = Bundle.main.bundleIdentifier else {
                return
            }
            let logger = OSLog(subsystem: bundle, category: "MacMagazineApp")
            os_log("%{public}@", log: logger, message)
            FileManager.default.save(message)
        }
    }
}

internal extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date)
    }
}

public func logD(_ object: Any?,
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 funcName: String = #function) {
    Log.debug(object, filename: filename, line: line, column: column, funcName: funcName)
}

public func logI(_ object: Any?,
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 funcName: String = #function) {
    Log.info(object, filename: filename, line: line, column: column, funcName: funcName)
}

public func logW(_ object: Any?,
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 funcName: String = #function) {
    Log.warning(object, filename: filename, line: line, column: column, funcName: funcName)
}

public func logE(_ object: Any?,
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 funcName: String = #function) {
    Log.error(object, filename: filename, line: line, column: column, funcName: funcName)
}

extension FileManager {
    fileprivate var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    fileprivate func save(_ content: String) {
        let url = documentsDirectory.appendingPathComponent("log.txt")

        if FileManager.default.fileExists(atPath: url.path),
           let fileHandle = try? FileHandle(forWritingTo: url),
           let data = "\(content)\n".data(using: .utf8) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        } else {
            try? "\(content)\n".write(to: url, atomically: true, encoding: .utf8)
        }
    }
}
