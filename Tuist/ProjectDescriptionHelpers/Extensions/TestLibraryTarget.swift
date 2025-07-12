
import ProjectDescription

public extension Target {
    static func libraryTestTarget(_ name: String) -> Target {
        .target(
            name: "\(name)Tests",
            destinations: [
                Destination.iPhone,
                Destination.iPad,
                Destination.appleTv,
                Destination.appleVision,
                Destination.appleWatch,
                Destination.mac,
                Destination.macCatalyst,
                Destination.macWithiPadDesign
            ],
            product: .unitTests,
            bundleId: "cloud.tuistpin.swift.tests",
            sources: ["Tests/\(name)/**"],
            dependencies: [
                .target(name: name)
            ],
            settings: Settings.testSettings(organizationName: Constants.organizationName,
                                            developmentTeam: Constants.developmentTeam,
                                            swiftVersion: "6.1",
                                            version: "1.0.0",
                                            buildVersion: "1")
        )
    }
}
