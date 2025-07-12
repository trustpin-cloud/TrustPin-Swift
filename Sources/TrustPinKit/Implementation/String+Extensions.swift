/// Extension for handling base64URL to base64 conversion with proper padding.
///
/// This extension provides mathematically correct base64 padding logic that ensures
/// proper conversion from base64URL format to standard base64 format.
extension String {
    /// Converts a base64URL encoded string to properly padded base64 format.
    ///
    /// Base64URL encoding uses '-' and '_' instead of '+' and '/' respectively,
    /// and omits padding characters. This computed property converts base64URL to
    /// standard base64 and adds the mathematically correct padding.
    ///
    /// ## Mathematical Basis
    ///
    /// Base64 encoding represents 3 bytes (24 bits) as 4 characters (6 bits each).
    /// Valid base64 strings must have lengths divisible by 4:
    /// - remainder 0: no padding needed
    /// - remainder 2: add 2 padding characters ("==")
    /// - remainder 3: add 1 padding character ("=")
    /// - remainder 1: invalid base64 state (should never occur in valid input)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let base64url = "SGVsbG8gV29ybGQ"
    /// let base64 = base64url.trustpinBase64URLPadded
    /// // Result: "SGVsbG8gV29ybGQ="
    /// ```
    ///
    /// - Important: This handles the conversion from base64URL (RFC 4648 Section 5) to base64 (RFC 4648 Section 4).
    /// - Note: Input with remainder 1 indicates corrupted or invalid base64URL data.
    var trustpinBase64URLPadded: String {
        // Convert base64URL characters to base64
        let base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Calculate required padding using modular arithmetic
        let paddingLength = (4 - (base64.count % 4)) % 4
        
        // Add the calculated padding
        return base64 + String(repeating: "=", count: paddingLength)
    }
}
