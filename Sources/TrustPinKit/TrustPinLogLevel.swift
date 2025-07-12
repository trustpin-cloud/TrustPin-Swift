//
//  TrustPinLog.swift
//  TrustPinKit
//
//  Defines the severity levels used by the TrustPin logging system.
//

import Foundation

/// Represents the severity level of a log message.
///
/// Used by the TrustPin logging infrastructure to control what types of messages are recorded or displayed.
public enum TrustPinLogLevel: Int, Sendable {
    /// Logging is disabled.
    case none = 0

    /// Log only error-level messages.
    case error = 1

    /// Log informational messages and errors.
    case info = 2

    /// Log debug, informational, and error messages.
    case debug = 3
}
