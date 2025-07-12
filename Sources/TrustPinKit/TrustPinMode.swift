import Foundation

/// Defines the behavior for handling unregistered domains in TrustPin certificate pinning.
///
/// This enum controls how TrustPin behaves when attempting to verify certificates for domains
/// that are not configured in your pinning configuration. The choice between modes affects
/// both security posture and application flexibility.
///
/// ## Security Considerations
///
/// Choose your pinning mode based on your security requirements and application architecture:
///
/// - **Production applications**: Use ``strict`` mode to ensure all connections are validated
/// - **Development/Testing**: Use ``permissive`` mode to allow connections to test servers
/// - **Hybrid applications**: Use ``permissive`` mode when connecting to dynamic third-party services
///
/// ## Usage Examples
///
/// ### Strict Mode (Production)
/// ```swift
/// try await TrustPin.setup(
///     organizationId: "prod-org-123",
///     projectId: "mobile-app-v2",
///     publicKey: "LS0tLS1CRUdJTi...",
///     mode: .strict  // Recommended for production
/// )
/// ```
///
/// ### Permissive Mode (Development)
/// ```swift
/// try await TrustPin.setup(
///     organizationId: "dev-org-456",
///     projectId: "mobile-app-staging",
///     publicKey: "LS0tLS1CRUdJTk...",
///     mode: .permissive  // Allows unregistered domains
/// )
/// ```
///
/// ## Migration Strategy
///
/// When implementing certificate pinning in existing applications:
///
/// 1. **Phase 1**: Deploy with ``permissive`` mode to identify all domains
/// 2. **Phase 2**: Register critical domains in TrustPin dashboard
/// 3. **Phase 3**: Switch to ``strict`` mode for production security
///
/// ## Topics
///
/// ### Pinning Modes
/// - ``strict``
/// - ``permissive``
public enum TrustPinMode: Sendable {
    /// Strict mode: Enforces certificate pinning validation for all domains.
    ///
    /// In strict mode, TrustPin throws an error when attempting to verify certificates
    /// for domains that are not registered in your pinning configuration. This provides
    /// the highest level of security by ensuring all connections are explicitly validated.
    ///
    /// ## Behavior
    ///
    /// - **Registered domains**: Certificate validation performed against configured pins
    /// - **Unregistered domains**: Throws ``TrustPinErrors/domainNotRegistered``
    /// - **Pin mismatches**: Throws ``TrustPinErrors/pinsMismatch``
    /// - **Expired pins**: Throws ``TrustPinErrors/allPinsExpired``
    ///
    /// ## Use Cases
    ///
    /// - ✅ **Production applications** with known, fixed API endpoints
    /// - ✅ **High-security environments** requiring comprehensive validation
    /// - ✅ **Compliance requirements** mandating certificate pinning
    /// - ✅ **Critical infrastructure** applications
    ///
    /// ## Security Benefits
    ///
    /// - **Complete coverage**: Ensures no unvalidated connections
    /// - **Attack prevention**: Blocks connections to potentially compromised domains
    /// - **Audit compliance**: Provides clear security posture for audits
    /// - **Incident detection**: Alerts when unexpected domains are accessed
    ///
    /// - Important: This is the recommended mode for production environments.
    /// - Note: Requires all domains to be registered in TrustPin dashboard before use.
    case strict
    
    /// Permissive mode: Allows selective certificate pinning validation.
    ///
    /// In permissive mode, TrustPin validates certificates for registered domains while
    /// allowing connections to unregistered domains to proceed without pinning validation.
    /// This provides flexibility for applications that need to connect to dynamic services
    /// while still securing critical API endpoints.
    ///
    /// ## Behavior
    ///
    /// - **Registered domains**: Certificate validation performed against configured pins
    /// - **Unregistered domains**: Bypasses pinning validation with informational log message
    /// - **Pin mismatches**: Throws ``TrustPinErrors/pinsMismatch`` for registered domains
    /// - **Expired pins**: Throws ``TrustPinErrors/allPinsExpired`` for registered domains
    ///
    /// ## Use Cases
    ///
    /// - ✅ **Development and staging** environments with test servers
    /// - ✅ **Applications with dynamic endpoints** (user-generated content, third-party services)
    /// - ✅ **Gradual migration** to certificate pinning in existing applications
    /// - ✅ **Third-party SDK integrations** with unknown domains
    /// - ✅ **Hybrid applications** connecting to both controlled and external services
    ///
    /// ## Security Considerations
    ///
    /// While permissive mode provides flexibility, consider these security implications:
    ///
    /// - **Partial protection**: Only registered domains receive pinning validation
    /// - **Monitoring required**: Log unregistered domain access for security analysis
    /// - **Gradual hardening**: Plan migration to strict mode for production
    ///
    /// ## Migration Path
    ///
    /// Use permissive mode as a stepping stone to strict mode:
    ///
    /// ```swift
    /// // Phase 1: Identify all domains
    /// TrustPin.set(logLevel: .info)
    /// try await TrustPin.setup(mode: .permissive)
    ///
    /// // Phase 2: Register critical domains
    /// // (Register domains in TrustPin dashboard)
    ///
    /// // Phase 3: Enforce strict validation
    /// try await TrustPin.setup(mode: .strict)
    /// ```
    ///
    /// - Note: Unregistered domain access is logged at info level for monitoring.
    /// - Important: Consider upgrading to strict mode once all critical domains are registered.
    case permissive
}
