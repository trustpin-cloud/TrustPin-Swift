    import Foundation

/// A namespace for TrustPin core functionality.
///
/// TrustPin provides SSL certificate pinning functionality to prevent man-in-the-middle (MITM) attacks
/// by validating server certificates against pre-configured public key pins. The library supports
/// both strict and permissive validation modes to accommodate different security requirements.
///
/// ## Overview
///
/// TrustPin delivers pinning configurations to your application. All operations are designed to work with Swift's
/// modern concurrency model using `async`/`await`.
///
/// ## Basic Usage
///
/// ```swift
/// import TrustPinKit
///
/// // Initialize TrustPin with your project credentials
/// try await TrustPin.setup(
///     organizationId: "your-org-id",
///     projectId: "your-project-id",
///     publicKey: "your-base64-public-key",
///     mode: .strict
/// )
///
/// // Verify a certificate manually
/// try await TrustPin.verify(
///     domain: "api.example.com",
///     certificate: pemCertificate
/// )
/// ```
///
/// ## Integration with URLSession
///
/// For automatic certificate validation with URLSession:
///
/// ```swift
/// let trustPinDelegate = TrustPinURLSessionDelegate()
/// let session = URLSession(
///     configuration: .default,
///     delegate: trustPinDelegate,
///     delegateQueue: nil
/// )
/// ```
///
/// ## Pinning Modes
///
/// - ``TrustPinMode/strict``: Throws errors for unregistered domains (recommended for production)
/// - ``TrustPinMode/permissive``: Allows unregistered domains to bypass pinning (development/testing)
///
/// ## Error Handling
///
/// TrustPin provides detailed error information through ``TrustPinErrors`` for proper
/// error handling and security monitoring.
///
/// ## Thread Safety
///
/// All TrustPin operations are thread-safe and can be called from any queue.
/// Internal operations are performed on appropriate background queues.
///
/// - Note: Always call ``setup(organizationId:projectId:publicKey:mode:)`` before performing certificate verification.
/// - Important: Use ``TrustPinMode/strict`` mode in production environments for maximum security.
public final class TrustPin {
    /// Initializes the TrustPin core library with the specified configuration.
    ///
    /// This method configures TrustPin with your organization credentials and fetches
    /// the pinning configuration from the TrustPin service. The configuration is cached
    /// for 10 minutes to optimize performance and reduce network requests.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// // Production setup with strict mode
    /// try await TrustPin.setup(
    ///     organizationId: "prod-org-123",
    ///     projectId: "mobile-app-v2",
    ///     publicKey: "LS0tLS1CRUdJTi...",
    ///     mode: .strict
    /// )
    ///
    /// // Development setup with permissive mode
    /// try await TrustPin.setup(
    ///     organizationId: "dev-org-456",
    ///     projectId: "mobile-app-staging",
    ///     publicKey: "LS0tLS1CRUdJTk...",
    ///     mode: .permissive
    /// )
    /// ```
    ///
    /// ## Setup Behavior
    ///
    /// - **Expected usage**: Call this method only once during your app's lifecycle
    /// - **Concurrent calls**: Not supported - ensure single-threaded setup
    /// - **Simplicity**: No complex state checking - trusts proper usage
    ///
    /// ## Security Considerations
    ///
    /// - **Production**: Always use ``TrustPinMode/strict`` mode to ensure all connections are validated
    /// - **Development**: Use ``TrustPinMode/permissive`` mode to allow connections to unregistered domains
    /// - **Credentials**: Keep your public key secure and never commit it to version control in plain text
    ///
    /// ## Network Requirements
    ///
    /// This method requires network access to fetch the pinning configuration from
    /// `https://cdn.trustpin.cloud`. Ensure your app has appropriate network permissions
    /// and can reach this endpoint.
    ///
    /// - Parameters:
    ///   - organizationId: Your organization identifier from the TrustPin dashboard
    ///   - projectId: Your project identifier from the TrustPin dashboard
    ///   - publicKey: Base64-encoded public key for signature verification
    ///   - mode: The pinning mode controlling behavior for unregistered domains (default: `.strict`)
    ///
    /// - Throws: ``TrustPinErrors/invalidProjectConfig`` if credentials are invalid or empty
    /// - Throws: ``TrustPinErrors/errorFetchingPinningInfo`` if network request fails
    /// - Throws: ``TrustPinErrors/configurationValidationFailed`` if signature verification fails
    ///
    /// - Important: This method must be called before any certificate verification operations.
    /// - Important: Only call this method once during your app's lifecycle.
    /// - Note: Configuration is automatically cached for 10 minutes to improve performance.
    public static func setup(organizationId: String,
                             projectId: String,
                             publicKey: String,
                             mode: TrustPinMode = .strict) async throws {
        let organizationId = organizationId.trimmingCharacters(in: .whitespacesAndNewlines)
        let projectId = projectId.trimmingCharacters(in: .whitespacesAndNewlines)
        let publicKey = publicKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if organizationId.isEmpty || projectId.isEmpty || publicKey.isEmpty {
            throw TrustPinErrors.invalidProjectConfig
        }
        
        // Perform actual setup
        try await TrustPinImpl.setup(organizationId: organizationId,
                                     projectId: projectId,
                                     publicKey: publicKey,
                                     mode: mode)
        
        // Store configuration
        let configuration = TrustPinState.Configuration(
            organizationId: organizationId,
            projectId: projectId,
            publicKey: publicKey,
            mode: mode,
            setupTimestamp: Date()
        )
        
        await TrustPinState.shared.setConfiguration(configuration)
    }

    /// Verifies a certificate against the specified domain using public key pinning.
    ///
    /// This method performs certificate validation by comparing the certificate's public key
    /// against the configured pins for the specified domain. It supports both SHA-256 and
    /// SHA-512 hash algorithms for pin matching.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let pemCertificate = """
    /// -----BEGIN CERTIFICATE-----
    /// MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
    /// -----END CERTIFICATE-----
    /// """
    ///
    /// do {
    ///     try await TrustPin.verify(
    ///         domain: "api.example.com",
    ///         certificate: pemCertificate
    ///     )
    ///     print("Certificate is valid!")
    /// } catch TrustPinErrors.domainNotRegistered {
    ///     print("Domain not configured for pinning")
    /// } catch TrustPinErrors.pinsMismatch {
    ///     print("Certificate doesn't match configured pins")
    /// }
    /// ```
    ///
    /// ## Security Behavior
    ///
    /// - **Registered domains**: Certificate validation is performed against configured pins
    /// - **Unregistered domains**: Behavior depends on the configured ``TrustPinMode``:
    ///   - ``TrustPinMode/strict``: Throws ``TrustPinErrors/domainNotRegistered``
    ///   - ``TrustPinMode/permissive``: Allows connection to proceed with info log
    ///
    /// ## Certificate Format
    ///
    /// The certificate must be in PEM format, including the BEGIN and END markers.
    /// Both single and multiple certificate chains are supported.
    ///
    /// - Parameters:
    ///   - domain: The domain name to validate (e.g., "api.example.com")
    ///   - certificate: PEM-encoded certificate string with BEGIN/END markers
    ///
    /// - Throws: ``TrustPinErrors/domainNotRegistered`` if domain is not configured (strict mode only)
    /// - Throws: ``TrustPinErrors/pinsMismatch`` if certificate doesn't match any configured pins
    /// - Throws: ``TrustPinErrors/allPinsExpired`` if all pins for the domain have expired
    /// - Throws: ``TrustPinErrors/invalidServerCert`` if certificate format is invalid
    ///
    /// - Important: Call ``setup(organizationId:projectId:publicKey:mode:)`` before using this method.
    /// - Note: This method is thread-safe and can be called from any queue.
    public static func verify(domain: String, certificate: String) async throws {
        let state = TrustPinState.shared
        let config = try await state.getConfigurationForOperation()
        
        await TrustPinLog.shared.debug("TrustPin configuration for \(config.resourceName)")
        
        do {
            try await TrustPinImpl.verify(domain: domain, certificate: certificate)
        } catch {
            await TrustPinLog.shared.error(
                "TrustPin domain [\(domain)] verification failed: \(error.localizedDescription)"
            )
            throw error
        }
    }

    /// Sets the current log level for TrustPin's internal logging system.
    ///
    /// Logging helps with debugging certificate pinning issues and monitoring
    /// security events. Different log levels provide varying amounts of detail.
    ///
    /// ## Log Levels
    ///
    /// - ``TrustPinLogLevel/none``: No logging output
    /// - ``TrustPinLogLevel/error``: Only error messages
    /// - ``TrustPinLogLevel/info``: Errors and informational messages
    /// - ``TrustPinLogLevel/debug``: All messages including detailed debug information
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// // Enable debug logging for development
    /// await TrustPin.set(logLevel: .debug)
    ///
    /// // Minimal logging for production
    /// await TrustPin.set(logLevel: .error)
    ///
    /// // Disable all logging
    /// await TrustPin.set(logLevel: .none)
    /// ```
    ///
    /// ## Performance Considerations
    ///
    /// - **Production**: Use `.error` or `.none` to minimize performance impact
    /// - **Development**: Use `.debug` for detailed troubleshooting information
    /// - **Staging**: Use `.info` for balanced logging without excessive detail
    ///
    /// - Parameter level: The ``TrustPinLogLevel`` to use for filtering log messages
    ///
    /// - Note: This setting affects all TrustPin logging globally across your application.
    /// - Important: Set the log level before calling ``setup(organizationId:projectId:publicKey:mode:)`` for complete logging coverage.
    public static func set(logLevel: TrustPinLogLevel) async {
        await TrustPinLog.shared.setLogLevel(logLevel)
    }
}
