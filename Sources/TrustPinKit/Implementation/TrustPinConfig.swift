import Foundation
import CryptoKit

/// A concurrency-safe configuration entity that stores TrustPin setup data and handles configuration retrieval.
actor TrustPinConfig {

    static let shared = TrustPinConfig()

    private var organizationId: String = ""
    private var projectId: String = ""
    private var publicKeyData: Data?
    private var mode: TrustPinMode = .strict

    private var cachedPayload: TrustPinPayload?
    private var lastFetchDate: Date?
    private var fetchingTask: Task<TrustPinPayload, Error>?

    private init() {}

    /// Resets the configuration to uninitialized state.
    /// This is primarily used for testing and should not be called in production code.
    func reset() {
        organizationId = ""
        projectId = ""
        mode = .strict
        publicKeyData = nil
        cachedPayload = nil
        lastFetchDate = nil
        fetchingTask?.cancel()
        fetchingTask = nil
    }

    /// Initializes or updates the TrustPin configuration and clears any cached data.
    func setup(organizationId: String, projectId: String, publicKey: String, mode: TrustPinMode = .strict) throws {
        self.organizationId = organizationId
        self.projectId = projectId
        self.mode = mode
        
        guard publicKey.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {
            throw TrustPinErrors.invalidProjectConfig
        }
        let publicKeyData = Data(base64Encoded: publicKey)
        guard let keyData = publicKeyData else {
            throw TrustPinErrors.invalidProjectConfig
        }
        
        self.publicKeyData = keyData
        self.cachedPayload = nil
        self.lastFetchDate = nil
        self.fetchingTask = nil
    }

    /// Returns a stable resource name for this configuration.
    func getResourceName() -> String {
        return "tprn::project::\(organizationId)::\(projectId)"
    }

    func getDefaultConfigurationURL() async -> URL? {
        return URL(string: "\(TrustPinConstants.cdnBaseURL)/\(organizationId)/\(projectId)/jws.b64")
    }
    
    /// Returns the current pinning mode.
    func getMode() -> TrustPinMode {
        return mode
    }
    
    /// Fetches the configuration from a given URL, using a cache if the last fetch was within 10 minutes.
    ///
    /// - Parameter url: The URL to fetch the configuration from.
    /// - Returns: The decoded configuration object.
    /// - Throws: `TrustPinError.errorFetchingPinningInfo` if the fetch fails and no cache is available.
    func getConfiguration(from url: URL) async throws -> TrustPinPayload {
        guard publicKeyData != nil else {
            throw TrustPinErrors.invalidProjectConfig
        }

        let now = Date()
        if let payload = cachedPayload, let lastFetch = lastFetchDate, now.timeIntervalSince(lastFetch) < TrustPinConstants.configCacheDuration {
            await TrustPinLog.shared.debug(
                "Using cached pinning payload, valid for \(Int(TrustPinConstants.configCacheDuration - now.timeIntervalSince(lastFetch))) more seconds."
            )
            return payload
        }

        await TrustPinLog.shared.debug("No valid cache, starting new configuration fetch.")

        if let task = fetchingTask {
            await TrustPinLog.shared.debug("Other task is fetching JWT. Waiting...")
            return try await task.value
        }

        let task = Task<TrustPinPayload, Error> {
            do {
                for attempt in 1...3 {
                    await TrustPinLog.shared.debug("Attempt \(attempt): Fetching JWT from \(url.absoluteString)")
                    do {
                        try await downloadConfiguration(url: url, attempt: attempt)
                        if let cached = self.cachedPayload {
                            await TrustPinLog.shared.info("Successfully fetched and cached pinning payload.")
                            clearFetchingTask()
                            return cached
                        }
                    } catch {
                        await TrustPinLog.shared.debug("Attempt \(attempt) failed: \(error)")
                    }
                }

                // All attempts failed
                if let cached = self.cachedPayload {
                    await TrustPinLog.shared.info("Returning stale pinning payload after all retries failed.")
                    clearFetchingTask()
                    return cached
                } else {
                    await TrustPinLog.shared.error("Failed to fetch and verify pinning payload.")
                    clearFetchingTask()
                    throw TrustPinErrors.errorFetchingPinningInfo
                }
            } catch {
                clearFetchingTask()
                throw error
            }
        }

        self.fetchingTask = task
        return try await task.value
    }

    static func convertRawToDER(signature rawSignature: Data) throws -> Data {
        guard rawSignature.count == 64 else {
            throw TrustPinErrors.configurationValidationFailed
        }

        let componentR = rawSignature.prefix(32)
        let componentS = rawSignature.suffix(32)

        func encodeASN1Integer(_ int: Data) -> Data {
            var bytes = [UInt8](int)
            if bytes.first ?? 0 >= 0x80 {
                bytes.insert(0x00, at: 0)
            }
            return Data([0x02, UInt8(bytes.count)]) + Data(bytes)
        }

        let rEnc = encodeASN1Integer(componentR)
        let sEnc = encodeASN1Integer(componentS)
        let sequence = rEnc + sEnc

        return Data([0x30, UInt8(sequence.count)]) + sequence
    }
    
    fileprivate func downloadConfiguration(url: URL, attempt: Int = 0) async throws {
        do {
            guard let publicKeyData else {
                throw TrustPinErrors.invalidProjectConfig
            }

            await TrustPinLog.shared.debug("[\(attempt)] Configuration URL: \(url)")
            let (data, _) = try await URLSession(configuration: .ephemeral).data(from: url)
            guard let jwtString = String(data: data, encoding: .utf8) else {
                await TrustPinLog.shared.error("[\(attempt)] Invalid JWT structure or Base64 decoding failed.")
                throw TrustPinErrors.errorFetchingPinningInfo
            }
            
            let segments = jwtString.split(separator: ".")
            
            await TrustPinLog.shared.debug("[\(attempt)] Segment[1] raw: \(segments[1])")
            await TrustPinLog.shared.debug("[\(attempt)] Padded: \(String(segments[1]).trustpinBase64URLPadded)")
            
            guard segments.count == 3,
                  let payloadData = Data(base64Encoded: String(segments[1]).trustpinBase64URLPadded),
                  let signatureData = Data(base64Encoded: String(segments[2]).trustpinBase64URLPadded) else {
                await TrustPinLog.shared.error("[\(attempt)] Invalid JWT structure or Base64 decoding failed.")
                throw TrustPinErrors.configurationValidationFailed
            }
            
            let message = Data("\(segments[0]).\(segments[1])".utf8)
            
            let publicKey: P256.Signing.PublicKey
            if #available(iOS 14.0, tvOS 14.0, *) {
                publicKey = try P256.Signing.PublicKey(derRepresentation: publicKeyData)
            } else {
                guard let rawKey = extractRawPublicKey(from: publicKeyData) else {
                    throw TrustPinErrors.invalidProjectConfig
                }
                publicKey = try P256.Signing.PublicKey(rawRepresentation: rawKey)
            }
            
            let derSignature = try TrustPinConfig.convertRawToDER(signature: signatureData)
            let signature = try P256.Signing.ECDSASignature(derRepresentation: derSignature)
            
            if !publicKey.isValidSignature(signature, for: message) {
                await TrustPinLog.shared.error("[\(attempt)] JWT signature verification failed.")
                throw TrustPinErrors.configurationValidationFailed
            }
            
            let payload = try JSONDecoder().decode(TrustPinPayload.self, from: payloadData)
            self.cachedPayload = payload
            self.lastFetchDate = Date()
            await TrustPinLog.shared.info("[\(attempt)] JWT successfully validated and pinning payload cached.")
        } catch {
            await TrustPinLog.shared.debug("[\(attempt)] There was an error while fetching the pinning info")
            await TrustPinLog.shared.error("[\(attempt)] Error: \(error.localizedDescription)")
            
            if (error as? TrustPinErrors) == .errorFetchingPinningInfo && attempt < 3 {
                await TrustPinLog.shared.debug("[\(attempt)] Retrying in 5 seconds...")
                try await Task.sleep(nanoseconds: 5_000_000_000)
            }
        }
    }
    
    private func clearFetchingTask() {
        self.fetchingTask = nil
    }
    
    private func extractRawPublicKey(from der: Data) -> Data? {
        // Skip ASN.1 headers to extract the last 33 bytes (compressed EC public key)
        guard der.count > 33 else { return nil }
        return der.suffix(33)
    }
}
