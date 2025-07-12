import ProjectDescription

public extension Target {
    static func libraryTarget(_ name: String, version: String, buildVersion: String) -> Target {
        return .target(
            name: name,
            destinations:  [
                Destination.iPhone,
                Destination.iPad,
                Destination.appleTv,
                Destination.appleVision,
                Destination.appleWatch,
                Destination.mac,
                Destination.macCatalyst,
                Destination.macWithiPadDesign
            ],
            product: .framework,
            productName: name,
            bundleId: "cloud.tuistpin.swift",
            deploymentTargets: DeploymentTargets.default(),
            sources: ["Sources/\(name)/**"],
            settings: Settings.librarySettings(organizationName: Constants.organizationName,
                                               developmentTeam: Constants.developmentTeam,
                                               swiftVersion: "6.1",
                                               version: version,
                                               buildVersion: buildVersion)
        )
    }
}
