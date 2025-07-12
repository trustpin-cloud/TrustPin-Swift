import Foundation

/// A URL session delegate that performs server trust evaluation using TrustPin's verification.
///
/// Implements certificate pinning by validating the server certificate against a domain-specific
/// whitelist using the `TrustPin.verify` method.
public final class TrustPinURLSessionDelegate: NSObject, URLSessionDelegate {
    /// Handles server trust challenges using an asynchronous TrustPin verification.
    ///
    /// - Parameters:
    ///   - session: The URL session containing the challenge.
    ///   - challenge: The authentication challenge received from the server.
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        return await handleServerTrustAsync(challenge: challenge)
    }
}
