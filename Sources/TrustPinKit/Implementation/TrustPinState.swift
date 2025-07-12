import Foundation

/// Simple state management for TrustPin SDK configuration.
///
/// This actor provides centralized state storage for the TrustPin configuration.
/// The user is expected to call setup() only once during the app lifecycle.
///
/// ## Thread Safety
///
/// This implementation uses Swift's actor model to ensure all state mutations
/// are performed on a single isolated queue.
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
internal actor TrustPinState {
    
    /// Configuration information for the TrustPin SDK.
    struct Configuration: Equatable {
        let organizationId: String
        let projectId: String
        let publicKey: String
        let mode: TrustPinMode
        let setupTimestamp: Date
        
        /// Resource name for this configuration.
        var resourceName: String {
            return String(format: TrustPinInternalConstants.resourceNameFormat, organizationId, projectId)
        }
    }
    
    // MARK: - Properties
    
    /// Current configuration (nil if not set up)
    private(set) var configuration: Configuration?
    
    /// Shared instance for global state management.
    static let shared = TrustPinState()
    
    // MARK: - Initialization
    
    private init() {
        // Private initializer to enforce singleton pattern
    }
    
    // MARK: - State Management
    
    /// Sets the configuration. User is expected to call this only once.
    func setConfiguration(_ config: Configuration) async {
        configuration = config
        await TrustPinLog.shared.info("TrustPin SDK initialization completed successfully")
    }
    
    /// Resets the SDK to uninitialized state.
    ///
    /// This is primarily used for testing and should not be called in production code.
    func reset() async {
        configuration = nil
        
        // Also reset the configuration state
        await TrustPinConfig.shared.reset()
    }
    
    // MARK: - State Queries
    
    /// Returns true if the SDK is ready for operations.
    func isReady() -> Bool {
        return configuration != nil
    }
    
    /// Returns the current configuration if available.
    func getConfiguration() -> Configuration? {
        return configuration
    }
    
    /// Gets the configuration for an operation.
    ///
    /// - Returns: The current configuration if SDK is ready.
    /// - Throws: `TrustPinErrors.invalidProjectConfig` if not configured.
    func getConfigurationForOperation() throws -> Configuration {
        guard let config = configuration else {
            throw TrustPinErrors.invalidProjectConfig
        }
        return config
    }
}
