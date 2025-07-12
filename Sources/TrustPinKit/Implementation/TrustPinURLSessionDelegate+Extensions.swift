import Foundation

internal extension TrustPinURLSessionDelegate {
    /// Performs asynchronous server certificate validation using TrustPin.
    ///
    /// Converts the server certificate to PEM format and calls `TrustPin.verify`.
    ///
    /// - Parameter challenge: The server trust challenge.
    /// - Returns: A tuple with the disposition (`useCredential` or `cancelAuthenticationChallenge`)
    func handleServerTrustAsync(
        challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            return (.performDefaultHandling, nil)
        }

        let domain = challenge.protectionSpace.host

        var trustResult = SecTrustResultType.invalid
        if #available(iOS 13.0, *) {
            var error: CFError?
            if !SecTrustEvaluateWithError(serverTrust, &error) {
                return (.cancelAuthenticationChallenge, nil)
            }
        } else {
            guard SecTrustEvaluate(serverTrust, &trustResult) == errSecSuccess,
                  trustResult == .unspecified || trustResult == .proceed else {
                return (.cancelAuthenticationChallenge, nil)
            }
        }

        guard let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return (.cancelAuthenticationChallenge, nil)
        }

        let serverCertData = SecCertificateCopyData(serverCert) as Data
        let certPEM = "-----BEGIN CERTIFICATE-----\n" +
                      serverCertData.base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed]) +
                      "\n-----END CERTIFICATE-----"

        do {
            try await verify(domain: domain, certificate: certPEM)
            let credential = URLCredential(trust: serverTrust)
            return (.useCredential, credential)
        } catch {
            return (.cancelAuthenticationChallenge, nil)
        }
    }

    /// Verifies a PEM-encoded certificate for a given domain using TrustPin.
    ///
    /// - Parameters:
    ///   - domain: The domain to verify.
    ///   - certificate: The PEM-encoded certificate string.
    /// - Throws: An error if verification fails.
    func verify(domain: String, certificate: String) async throws {
        try await TrustPin.verify(domain: domain, certificate: certificate)
    }
}
