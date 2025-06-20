# TrustPin iOS SDK

TrustPin is a lightweight and secure iOS library designed to enforce **Certificate Pinning** for native apps, following OWASP recommendations. It enables developers to prevent MITM attacks by ensuring server authenticity at the TLS level.

---

## Features

- ✅ Certificate and Public Key Pinning (via SHA256, SHA512)
- ✅ Asynchronous verification using Swift Concurrency
- ✅ `URLSessionDelegate` for drop-in HTTPS validation
- ✅ Compatible with popular networking clients (Alamofire, Moya, and more!)

---

## Platform Requirements

TrustPinKit supports the following minimum platform versions:

- iOS 13+
- macOS 13+
- Mac Catalyst 13+
- watchOS 7+
- tvOS 13+

---

## Installation

### Swift Package Manager (Recommended)

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/trustpin-cloud/TrustPin-Swift", from: "1.0.0")
]
```

Then include `TrustPinKit` as a dependency in your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "TrustPinKit", package: "TrustPin-Swift")
    ]
)
```

---

## Setup

Before verifying certificates, you must initialize the SDK with your organization ID, project ID, and a trusted public key:

```swift
import TrustPinKit

try await TrustPin.setup(
    organizationId: "my-org-id",
    projectId: "my-project-id",
    publicKey: "base64-encoded-public-key"
)
```

You will find this information in your project's settings at https://trustpin.cloud

---

## Usage with URLSessionDelegate

To automatically validate HTTPS responses via certificate pinning, use the provided `TrustPinURLSessionDelegate`:

```swift
let delegate = TrustPinURLSessionDelegate()
let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)

let (data, response) = try await session.data(from: URL(string: "https://api.example.com")!)
```

---

## Advanced Usage – Manual Certificate Verification

You can manually verify a certificate string in PEM format for a specific domain:

```swift
let domain = "api.example.com"
let pemEncodedCertificate = """
-----BEGIN CERTIFICATE-----
MIIB...
-----END CERTIFICATE-----
"""

try await TrustPin.verify(domain: domain, certificate: pemEncodedCertificate)
```

This can be useful in custom networking stacks, or when inspecting certificate chains manually.

## Non-registered domains in TrustPin

The default configuration for non-registered domains is to grant access to them and perform the network request.  

---

## Documentation

Source code documentation is available at [https://trustpin-cloud.github.io/TrustPin-Swift/](https://trustpin-cloud.github.io/TrustPin-Swift/).

---

## License

All rights reserved to TrustPin (c) 2025.

---

## Feedback

We welcome your feedback! Reach out to us at [https://trustpin.cloud/contact](https://trustpin.cloud/contact)
