import Foundation
import CryptoKit

/// A concurrency-safe implementation of the TrustPin certificate pinning library.
actor TrustPinImpl {

    /// Initializes the TrustPin core library with the given project ID and public key.
    ///
    /// This function sets up the core functionality necessary for certificate pinning.
    /// It returns an error if the setup fails for reasons such as an invalid project identifier
    /// or incorrect public key format.
    ///
    /// - Parameters:
    ///   - organizationId: A string that identifies the organization project.
    ///   - projectId: A string that identifies the project within the organization.
    ///   - publicKey: A base64-encoded string representing the public key.
    ///   - mode: The pinning mode that controls behavior for unregistered domains.
    /// - Throws: A `TrustPinError` if setup fails.
    static func setup(organizationId: String, projectId: String, publicKey: String, mode: TrustPinMode) async throws {
        try await TrustPinConfig.shared.setup(
            organizationId: organizationId,
            projectId: projectId,
            publicKey: publicKey,
            mode: mode
        )
    }

    /// Verifies a certificate against the specified domain using public key pinning.
    ///
    /// This function performs an asynchronous verification of a certificate,
    /// ensuring it matches the expected public key for the domain.
    ///
    /// - Parameters:
    ///   - domain: The domain name associated with the certificate.
    ///   - certificate: The PEM-encoded certificate string to verify.
    /// - Throws: An error if verification fails or if the result cannot be determined.
    static func verify(domain: String, certificate pem: String) async throws {
        let payload: TrustPinPayload
        do {
            guard let url = await TrustPinConfig.shared.getDefaultConfigurationURL() else {
                throw TrustPinErrors.invalidProjectConfig
            }
            payload = try await TrustPinConfig.shared.getConfiguration(from: url)
        } catch {
            throw TrustPinErrors.errorFetchingPinningInfo
        }

        let sanitized = sanitizeDomain(domain)
        let der = try convertPEMToDER(pem)
        guard let domainEntry = try await findMatchingDomain(payload, for: sanitized) else {
            // Check pinning mode for unregistered domains
            let mode = await TrustPinConfig.shared.getMode()
            switch mode {
            case .strict:
                throw TrustPinErrors.domainNotRegistered
            case .permissive:
                await TrustPinLog.shared.info("No pinning for host: \(sanitized), bypassing due to permissive mode")
                return // Allow unregistered domains to bypass pinning
            }
        }
        try await verifyCertificate(der, against: domainEntry, originalDomain: domain)
    }

    fileprivate static func sanitizeDomain(_ domain: String) -> String {
        return domain
            .lowercased()
            .replacingOccurrences(of: "^https?://", with: "", options: .regularExpression)
            .split(separator: "/")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? domain
    }

    fileprivate static func convertPEMToDER(_ pem: String) throws -> Data {
        let lines = pem.components(separatedBy: .newlines)
            .filter { !$0.hasPrefix("-----") && !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard let der = Data(base64Encoded: lines.joined()) else {
            throw TrustPinErrors.invalidServerCert
        }
        return der
    }

    fileprivate static func findMatchingDomain(
        _ payload: TrustPinPayload,
        for domain: String
    ) async throws -> Domain? {
        let matchingDomains = payload.domains.filter {
            $0.domain.lowercased() == domain
        }

        if matchingDomains.isEmpty {
            await TrustPinLog.shared.debug("No pinning for host: \(domain)")
            return nil
        }

        guard matchingDomains.count == 1, let domainEntry = matchingDomains.first else {
            await TrustPinLog.shared.error("Multiple pinning entries found for host: \(domain)")
            throw TrustPinErrors.invalidProjectConfig
        }
        return domainEntry
    }

    fileprivate static func verifyCertificate(
        _ der: Data,
        against domain: Domain,
        originalDomain: String
    ) async throws {
        var anyValidPin: Bool = false

        for pin in domain.pins {
            if pin.isExpired() {
                continue
            }

            anyValidPin = true

            let certHash: Data
            switch pin.alg.lowercased() {
            case "sha256":
                certHash = Data(SHA256.hash(data: der))
            case "sha512":
                certHash = Data(SHA512.hash(data: der))
            default:
                await TrustPinLog.shared.error(
                    "Unknown algorithm: \(pin.alg) detected in pin configuration for domain: \(domain.domain)"
                )
                continue // Unknown algorithm, ignore
            }

            if certHash.base64EncodedString() == pin.pin {
                await TrustPinLog.shared.info("Valid pin found for \(domain.domain)")
                return
            }
        }

        if anyValidPin {
            throw TrustPinErrors.pinsMismatch
        } else {
            throw TrustPinErrors.allPinsExpired
        }
    }
}
