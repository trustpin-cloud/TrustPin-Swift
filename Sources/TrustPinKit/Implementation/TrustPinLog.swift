import Foundation

/// Global singleton logger
actor TrustPinLog {
    static let shared = TrustPinLog()

    private var logLevel: TrustPinLogLevel = .info

    /// Sets the current log level for the logger.
    ///
    /// - Parameter level: The `TrustPinLogLevel` to use for filtering messages.
    func setLogLevel(_ level: TrustPinLogLevel) {
        self.logLevel = level
    }

    /// Returns the currently set log level.
    ///
    /// - Returns: The `TrustPinLogLevel` currently in use.
    func getLogLevel() -> TrustPinLogLevel {
        return self.logLevel
    }

    /// Logs a debug-level message asynchronously.
    ///
    /// - Parameter message: The message to log.
    func debug(_ message: String) async {
        await log(.debug, message)
    }

    /// Logs an info-level message asynchronously.
    ///
    /// - Parameter message: The message to log.
    func info(_ message: String) async {
        await log(.info, message)
    }

    /// Logs an error-level message asynchronously.
    ///
    /// - Parameter message: The message to log.
    func error(_ message: String) async {
        await log(.error, message)
    }

    /// Logs a message at the specified log level if allowed by the current log level.
    ///
    /// - Parameters:
    ///   - level: The severity level of the message.
    ///   - message: The message to log.
    private func log(_ level: TrustPinLogLevel, _ message: String) async {
        guard level.rawValue <= logLevel.rawValue, logLevel != .none else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        print("TrustPin [\(timestamp)] [\(levelString(level))] \(message)")
    }

    /// Converts a `TrustPinLogLevel` to its string representation.
    ///
    /// - Parameter level: The log level to convert.
    /// - Returns: A string representing the log level.
    private func levelString(_ level: TrustPinLogLevel) -> String {
        switch level {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .error: return "ERROR"
        case .none: return "NONE"
        }
    }
}
