import Foundation

/// Configuration constants for TrustPin SDK.
///
/// This enum contains configurable constants that were previously hardcoded
/// throughout the SDK. Centralizing these values improves maintainability
/// and allows for easier configuration tuning.
internal enum TrustPinConstants {
    
    // MARK: - Network Configuration
    
    /// The base URL for TrustPin CDN where configurations are fetched.
    static let cdnBaseURL = "https://cdn.trustpin.cloud"
    
    /// Default timeout interval for network requests in seconds.
    static let defaultNetworkTimeout: TimeInterval = 30.0
    
    /// Maximum number of retry attempts for network operations.
    static let maxRetryAttempts = 3
    
    /// Initial retry delay in seconds (for exponential backoff).
    static let initialRetryDelay: TimeInterval = 1.0
    
    // MARK: - Caching Configuration
    
    /// Duration in seconds for which configuration is cached (10 minutes).
    static let configCacheDuration: TimeInterval = 10 * 60
    
    /// Maximum age in seconds for stale cache fallback (24 hours).
    static let staleCacheMaxAge: TimeInterval = 24 * 60 * 60
    
    // MARK: - Certificate Validation
    
    /// Supported hash algorithms for certificate pinning.
    enum HashAlgorithm: String, CaseIterable {
        case sha256 = "sha256"
        case sha512 = "sha512"
        
        /// All supported algorithm names for validation.
        static var allNames: [String] {
            return allCases.map { $0.rawValue }
        }
    }
    
    /// Expected algorithm for signature verification.
    static let expectedSignatureAlgorithm = "ES256"
    
    /// Expected type header value.
    static let expectedConfigurationType = "JWT"
    
    // MARK: - Performance Configuration
    
    /// Base64 encoding line length for PEM certificate formatting.
    static let base64LineLength = 64
    
    /// Maximum certificate chain length to process.
    static let maxCertificateChainLength = 10
    
    /// Queue label for TrustPin background operations.
    static let backgroundQueueLabel = "com.trustpin.ios.sdk.background"
    
    // MARK: - Security Configuration
    
    /// Maximum clock skew allowed for timestamp validation in seconds (5 minutes).
    static let maxClockSkew: TimeInterval = 5 * 60
    
    /// Minimum key size for ECDSA keys in bits.
    static let minimumECDSAKeySize = 256
    
    // MARK: - Error Configuration
    
    /// Error domain for TrustPin errors.
    static let errorDomain = "com.trustpin.ios.sdk.error"
    
    /// User info key for underlying error details.
    static let underlyingErrorKey = "underlyingError"
    
    /// User info key for affected domain name.
    static let domainNameKey = "domainName"
    
    // MARK: - Thread Safety Configuration
    
    /// Maximum concurrent operations for certificate validation.
    static let maxConcurrentValidations = 4
    
    /// Default quality of service for background operations.
    static let defaultQoS: DispatchQoS.QoSClass = .utility
}

/// Internal constants for implementation details.
internal enum TrustPinInternalConstants {
    
    /// Resource name format for TrustPin projects.
    static let resourceNameFormat = "tprn::project::%@::%@"
    
    /// Signature component separator.
    static let signatureComponentSeparator = "."
    
    /// Expected number of signature components.
    static let expectedSignatureComponentCount = 3
    
    /// PEM certificate begin marker.
    static let pemBeginMarker = "-----BEGIN CERTIFICATE-----"
    
    /// PEM certificate end marker.
    static let pemEndMarker = "-----END CERTIFICATE-----"
    
    /// Default user agent for network requests.
    static let userAgent = "TrustPin-iOS-SDK/1.0.0"
    
    /// Configuration cache key prefix.
    static let cacheKeyPrefix = "trustpin.config."
    
    /// Thread-local key for current domain context.
    static let domainContextKey = "trustpin.domain.context"
}
