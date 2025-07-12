import Foundation

/// Model for the decoded JWT payload.
struct KeyPin: Codable {
    let pin: String
    let alg: String
    let expiresAt: Int?

    enum CodingKeys: String, CodingKey {
        case pin
        case alg
        case expiresAt = "expires_at"
    }

    func isExpired() -> Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date().timeIntervalSince1970 > TimeInterval(expiresAt)
    }
}

struct Domain: Codable {
    let domain: String
    let lastUpdated: Int
    let pins: [KeyPin]
    
    enum CodingKeys: String, CodingKey {
        case domain
        case pins
        case lastUpdated = "last_updated"
    }
}

struct TrustPinPayload: Codable {
    let version: Int
    let domains: [Domain]
    let iat: Int
    let nbf: Int
    let exp: Int?

    enum CodingKeys: String, CodingKey {
        case version, domains, iat, nbf, exp
    }
}
