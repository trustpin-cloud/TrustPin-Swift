import Foundation

/// Represents possible errors thrown by the TrustPin library.
///
/// TrustPin provides detailed error information to help with debugging certificate pinning
/// issues and implementing appropriate error handling strategies. Each error case represents
/// a specific failure scenario with distinct security implications.
///
/// ## Error Categories
///
/// - **Configuration errors**: Issues with setup parameters or credentials
/// - **Network errors**: Problems fetching pinning configurations
/// - **Certificate errors**: Invalid or malformed certificates
/// - **Validation errors**: Certificate doesn't match configured pins
/// - **Security errors**: Potential security threats or policy violations
///
/// ## Example Error Handling
///
/// ```swift
/// do {
///     try await TrustPin.verify(domain: "api.example.com", certificate: cert)
/// } catch TrustPinErrors.domainNotRegistered {
///     // Handle unregistered domain (strict mode only)
///     logger.warning("Unregistered domain accessed")
/// } catch TrustPinErrors.pinsMismatch {
///     // Critical security issue - possible MITM attack
///     logger.critical("Certificate pinning failed")
///     throw SecurityError.potentialMITMAttack
/// } catch TrustPinErrors.invalidServerCert {
///     // Certificate format issue
///     logger.error("Invalid certificate format")
/// } catch TrustPinErrors.errorFetchingPinningInfo {
///     // Network connectivity issue
///     logger.error("Unable to fetch pinning configuration")
/// }
/// ```
///
/// ## Security Response Guidelines
///
/// - **``pinsMismatch``**: Treat as potential MITM attack, do not retry
/// - **``domainNotRegistered``**: Log for security monitoring, handle per mode
/// - **``allPinsExpired``**: Update pins urgently, consider emergency bypass
/// - **``invalidServerCert``**: Investigate certificate source and format
/// - **``errorFetchingPinningInfo``**: Retry with exponential backoff
/// - **``configurationValidationFailed``**: Check credentials and network integrity
/// - **``invalidProjectConfig``**: Verify credentials and configuration
///
/// ## Topics
///
/// ### Configuration Errors
/// - ``invalidProjectConfig``
///
/// ### Network Errors  
/// - ``errorFetchingPinningInfo``
/// - ``configurationValidationFailed``
///
/// ### Certificate Errors
/// - ``invalidServerCert``
///
/// ### Validation Errors
/// - ``pinsMismatch``
/// - ``allPinsExpired``
///
/// ### Security Errors
/// - ``domainNotRegistered``
public enum TrustPinErrors: Error {
    /// The project configuration is invalid or incomplete.
    ///
    /// This error occurs when the setup parameters provided to ``TrustPin/setup(organizationId:projectId:publicKey:mode:)``
    /// are invalid, missing, or incorrectly formatted.
    ///
    /// ## Common Causes
    ///
    /// - Empty or whitespace-only organization ID, project ID, or public key
    /// - Invalid base64 encoding in the public key
    /// - Incorrect credential format or structure
    /// - Network connectivity issues during credential validation
    ///
    /// ## Resolution Steps
    ///
    /// 1. **Verify credentials**: Check organization ID and project ID in TrustPin dashboard
    /// 2. **Validate public key**: Ensure proper base64 encoding without extra characters
    /// 3. **Check formatting**: Remove any whitespace, newlines, or special characters
    /// 4. **Test connectivity**: Verify network access to TrustPin service
    ///
    /// ## Example
    ///
    /// ```swift
    /// do {
    ///     try await TrustPin.setup(
    ///         organizationId: "org-123",
    ///         projectId: "project-456",
    ///         publicKey: "LS0tLS1CRUdJTi...",
    ///         mode: .strict
    ///     )
    /// } catch TrustPinErrors.invalidProjectConfig {
    ///     print("Invalid credentials - check TrustPin dashboard")
    /// }
    /// ```
    ///
    /// - Important: This error indicates a fundamental configuration issue that must be resolved before TrustPin can function.
    case invalidProjectConfig

    /// Failed to fetch or parse pinning information from the remote source.
    ///
    /// This error occurs when TrustPin cannot download the pinning configuration from
    /// the TrustPin CDN or when the downloaded configuration cannot be parsed.
    ///
    /// ## Common Causes
    ///
    /// - Network connectivity issues
    /// - DNS resolution failures for `cdn.trustpin.cloud`
    /// - Firewall or proxy blocking HTTPS requests
    /// - Service downtime or maintenance
    /// - Invalid response format from the server
    ///
    /// ## Resolution Steps
    ///
    /// 1. **Check connectivity**: Verify internet connection and DNS resolution
    /// 2. **Test endpoint**: Try accessing `https://cdn.trustpin.cloud` directly
    /// 3. **Review firewall**: Ensure HTTPS traffic to TrustPin CDN is allowed
    /// 4. **Retry with backoff**: Implement exponential backoff for transient failures
    /// 5. **Check service status**: Verify TrustPin service availability
    ///
    /// ## Retry Strategy
    ///
    /// ```swift
    /// func setupWithRetry() async throws {
    ///     for attempt in 1...3 {
    ///         do {
    ///             try await TrustPin.setup(/* credentials */)
    ///             return // Success
    ///         } catch TrustPinErrors.errorFetchingPinningInfo {
    ///             if attempt < 3 {
    ///                 try await Task.sleep(nanoseconds: UInt64(attempt * 1_000_000_000))
    ///             } else {
    ///                 throw TrustPinErrors.errorFetchingPinningInfo
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Note: This error may be temporary and retrying with exponential backoff is recommended.
    case errorFetchingPinningInfo

    /// The server certificate is invalid, corrupted, or could not be parsed.
    ///
    /// This error occurs when the certificate provided to ``TrustPin/verify(domain:certificate:)``
    /// is malformed, corrupted, or not in the expected PEM format.
    ///
    /// ## Common Causes
    ///
    /// - Invalid PEM format (missing BEGIN/END markers)
    /// - Corrupted certificate data
    /// - Incorrect encoding (not base64)
    /// - Truncated or incomplete certificate
    /// - Wrong certificate type (not X.509)
    ///
    /// ## Certificate Format Requirements
    ///
    /// Certificates must be in PEM format with proper markers:
    ///
    /// ```
    /// -----BEGIN CERTIFICATE-----
    /// MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
    /// -----END CERTIFICATE-----
    /// ```
    ///
    /// ## Resolution Steps
    ///
    /// 1. **Verify format**: Ensure certificate includes BEGIN/END markers
    /// 2. **Check encoding**: Validate base64 encoding within markers
    /// 3. **Test parsing**: Use OpenSSL or similar tool to validate certificate
    /// 4. **Source validation**: Verify certificate source and extraction method
    ///
    /// ## Example
    ///
    /// ```swift
    /// do {
    ///     try await TrustPin.verify(domain: "api.example.com", certificate: pemCert)
    /// } catch TrustPinErrors.invalidServerCert {
    ///     print("Certificate format is invalid - check PEM encoding")
    /// }
    /// ```
    ///
    /// - Important: This error indicates a problem with the certificate format, not the pinning validation.
    case invalidServerCert

    /// No matching pins were found for the provided certificate.
    ///
    /// This error occurs when the certificate's public key hash doesn't match any of the
    /// configured pins for the domain. This is a critical security error that may indicate
    /// a man-in-the-middle (MITM) attack or certificate rotation without pin updates.
    ///
    /// ## Security Implications
    ///
    /// - **High severity**: Potential security threat detected
    /// - **MITM attack**: Certificate may be compromised or intercepted
    /// - **Service disruption**: Legitimate certificate rotation without pin updates
    /// - **Configuration drift**: Pins may be outdated or incorrect
    ///
    /// ## Immediate Actions
    ///
    /// 1. **Do not retry**: This is not a transient error
    /// 2. **Log security event**: Record details for security monitoring
    /// 3. **Alert administrators**: Notify security team of potential threat
    /// 4. **Block connection**: Prevent potentially compromised connection
    ///
    /// ## Investigation Steps
    ///
    /// 1. **Verify certificate**: Check if server certificate changed legitimately
    /// 2. **Update pins**: If legitimate change, update pins in TrustPin dashboard
    /// 3. **Check network**: Investigate for network-level interference
    /// 4. **Review logs**: Look for patterns indicating broader compromise
    ///
    /// ## Example Handling
    ///
    /// ```swift
    /// do {
    ///     try await TrustPin.verify(domain: "api.example.com", certificate: cert)
    /// } catch TrustPinErrors.pinsMismatch {
    ///     // Critical security issue - do not retry
    ///     logger.critical("Certificate pinning failed for \(domain)")
    ///     securityMonitor.alert("Potential MITM attack detected")
    ///     throw SecurityError.potentialMITMAttack
    /// }
    /// ```
    ///
    /// - Important: This error should be treated as a potential security threat and investigated immediately.
    /// - Warning: Never ignore this error or implement automatic retries.
    case pinsMismatch

    /// All configured pins for the domain have expired.
    ///
    /// This error occurs when all the certificate pins configured for a domain have
    /// passed their expiration date. This indicates a maintenance issue that requires
    /// immediate attention to restore service availability.
    ///
    /// ## Common Causes
    ///
    /// - Expired certificates that weren't renewed in time
    /// - Outdated pin configuration in TrustPin dashboard
    /// - Certificate rotation without pin updates
    /// - Maintenance oversight or process failure
    ///
    /// ## Immediate Actions
    ///
    /// 1. **Check certificate validity**: Verify if server certificate is still valid
    /// 2. **Update pins**: Generate new pins for current certificates
    /// 3. **Emergency bypass**: Consider temporary permissive mode if critical
    /// 4. **Notify administrators**: Alert operations team of expiration
    ///
    /// ## Resolution Steps
    ///
    /// 1. **TrustPin dashboard**: Update expired pins with current certificate hashes
    /// 2. **Certificate renewal**: Renew certificates if they're also expired
    /// 3. **Process review**: Improve pin management and renewal processes
    /// 4. **Monitoring**: Set up alerts for upcoming pin expirations
    ///
    /// ## Emergency Bypass
    ///
    /// If immediate service restoration is critical:
    ///
    /// ```swift
    /// // Temporary permissive mode for emergency access
    /// try await TrustPin.setup(
    ///     organizationId: orgId,
    ///     projectId: projectId,
    ///     publicKey: publicKey,
    ///     mode: .permissive  // Temporary bypass
    /// )
    /// ```
    ///
    /// ## Prevention
    ///
    /// - **Monitoring**: Set up alerts 30 days before pin expiration
    /// - **Automation**: Implement automated pin renewal processes
    /// - **Staging testing**: Test pin updates in staging environment first
    /// - **Documentation**: Maintain clear pin management procedures
    ///
    /// - Important: This error requires immediate attention to restore secure connectivity.
    /// - Warning: Consider service impact before implementing emergency bypass procedures.
    case allPinsExpired

    /// The payload failed validation (e.g., signature mismatch or invalid structure).
    ///
    /// This error occurs when the validation fails for the
    /// downloaded pinning configuration. This indicates either a security issue or
    /// a configuration problem with the credentials.
    ///
    /// ## Common Causes
    ///
    /// - **Credential mismatch**: Public key doesn't match the signature
    /// - **Corrupted payload**: Network issues corrupted the downloaded configuration
    /// - **Tampering**: Potential man-in-the-middle attack on configuration
    /// - **Service issues**: Problems with TrustPin service signing
    /// - **Clock skew**: Timestamp validation failures due to incorrect system time
    ///
    /// ## Security Implications
    ///
    /// - **High severity**: Configuration integrity compromised
    /// - **Potential attack**: Configuration may have been tampered with
    /// - **Service disruption**: Cannot proceed with pinning validation
    /// - **Trust breakdown**: Fundamental security validation failed
    ///
    /// ## Resolution Steps
    ///
    /// 1. **Verify credentials**: Ensure public key matches TrustPin dashboard
    /// 2. **Check system time**: Verify device clock is accurate
    /// 3. **Test connectivity**: Ensure clean network path to TrustPin service
    /// 4. **Retry operation**: Attempt fresh configuration download
    /// 5. **Contact support**: If persistent, contact TrustPin support
    ///
    /// ## Diagnostic Information
    ///
    /// ```swift
    /// do {
    ///     try await TrustPin.setup(/* credentials */)
    /// } catch TrustPinErrors.configurationValidationFailed {
    ///     print("configuration validation failed - check credentials and network")
    ///     // Log additional context:
    ///     // - System time
    ///     // - Network conditions
    ///     // - Credential sources
    /// }
    /// ```
    ///
    /// ## Prevention
    ///
    /// - **Credential management**: Securely store and manage public keys
    /// - **Time synchronization**: Ensure accurate system time via NTP
    /// - **Network monitoring**: Monitor for network interference
    /// - **Validation testing**: Regularly test credential validation
    ///
    /// - Important: This error may indicate a security issue and should be investigated thoroughly.
    /// - Warning: Do not ignore this error as it may indicate configuration tampering.
    case configurationValidationFailed
    
    /// The domain is not registered for pinning and enforcement is enabled.
    ///
    /// This error occurs only in ``TrustPinMode/strict`` mode when attempting to verify
    /// a certificate for a domain that is not configured in your TrustPin pinning
    /// configuration. This enforces the security policy that all connections must be
    /// explicitly validated.
    ///
    /// ## When This Occurs
    ///
    /// - **Strict mode only**: This error is not thrown in ``TrustPinMode/permissive`` mode
    /// - **Unregistered domains**: Domain not found in TrustPin dashboard configuration
    /// - **Typos in domain**: Incorrect domain name or subdomain
    /// - **New services**: Recently added services not yet registered
    ///
    /// ## Resolution Steps
    ///
    /// 1. **Register domain**: Add domain to TrustPin dashboard with appropriate pins
    /// 2. **Verify domain name**: Check for typos or incorrect subdomain
    /// 3. **Update configuration**: Refresh TrustPin configuration if recently added
    /// 4. **Consider mode**: Evaluate if ``TrustPinMode/permissive`` is appropriate
    ///
    /// ## Domain Registration
    ///
    /// To register a domain in TrustPin:
    ///
    /// 1. **TrustPin Dashboard**: Log into your TrustPin account
    /// 2. **Add Domain**: Configure domain with certificate pins
    /// 3. **Generate Pins**: Create SHA-256 or SHA-512 hashes of certificates
    /// 4. **Set Expiration**: Configure appropriate expiration dates
    /// 5. **Test Configuration**: Verify in staging environment
    ///
    /// ## Example Handling
    ///
    /// ```swift
    /// do {
    ///     try await TrustPin.verify(domain: "new-api.example.com", certificate: cert)
    /// } catch TrustPinErrors.domainNotRegistered {
    ///     // Domain not configured for pinning
    ///     logger.warning("Unregistered domain accessed: \(domain)")
    ///     
    ///     // Options:
    ///     // 1. Register domain in TrustPin dashboard
    ///     // 2. Switch to permissive mode temporarily
    ///     // 3. Update application to handle unregistered domains
    /// }
    /// ```
    ///
    /// ## Security Considerations
    ///
    /// - **Intentional restriction**: This error enforces your security policy
    /// - **Audit trail**: Log these events for security monitoring
    /// - **Process improvement**: May indicate need for better domain management
    /// - **Compliance**: Helps maintain strict security compliance
    ///
    /// ## Migration Strategy
    ///
    /// When implementing strict mode:
    ///
    /// ```swift
    /// // Phase 1: Discovery with permissive mode
    /// await TrustPin.set(logLevel: .info)
    /// try await TrustPin.setup(mode: .permissive)
    /// 
    /// // Phase 2: Register discovered domains
    /// // (Use logs to identify all accessed domains)
    /// 
    /// // Phase 3: Enable strict mode
    /// try await TrustPin.setup(mode: .strict)
    /// ```
    ///
    /// - Note: This error only occurs in strict mode and is part of the security enforcement.
    /// - Important: Use this error as feedback to improve your domain registration process.
    case domainNotRegistered
}
