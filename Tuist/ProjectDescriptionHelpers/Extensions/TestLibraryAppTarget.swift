import ProjectDescription

public extension Target {
    static func testApp(_ name: String) -> Target {
        .target(
            name: "TestApp",
            destinations: [
                .iPhone,
                .iPad,
                .macCatalyst,
                .mac
            ],
            product: .app,
            bundleId: "cloud.tuistpin.swift.testapp",
            deploymentTargets: DeploymentTargets.multiplatform(
                iOS: "15.0",
                macOS: "14.0"
            ),
            sources: ["Sample/TestApp/**"],
            resources: ["Sample/TestApp/LaunchScreen.storyboard"],
            entitlements: "Sample/TestApp/TestApp.entitlements",
            dependencies: [.target(name: name)],
            settings: Settings.sampleAppSettings(
                organizationName: Constants.organizationName,
                developmentTeam: Constants.developmentTeam,
                swiftVersion: "6.1",
                version: "1.0.0",
                buildVersion: "1")
        )
    }
}
