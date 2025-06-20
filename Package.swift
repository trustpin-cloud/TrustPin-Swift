// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TrustPinKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v13),
        .macCatalyst(.v13),
        .watchOS(.v7),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "TrustPinKit",
            targets: ["TrustPinKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "TrustPinKit",
            url: "https://github.com/trustpin-cloud/TrustPin-Swift/releases/download/1.0.0/TrustPinKit-1.0.0.xcframework.zip",
            checksum: "682d9cac379bae531e4961097f890bf377af5b8c1ee45c912747fba12cab0595"
        )
    ]
)
