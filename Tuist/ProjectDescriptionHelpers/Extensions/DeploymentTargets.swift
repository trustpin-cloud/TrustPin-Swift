import ProjectDescription

public extension DeploymentTargets {
    static func `default`() -> DeploymentTargets {
        return DeploymentTargets.multiplatform(
            iOS: Constants.iOSTargetVersion,
            macOS: Constants.macOSTargetVersion,
            watchOS: Constants.watchOSTargetVersion,
            tvOS: Constants.tvOSTargetVersion,
            visionOS: Constants.visionOSTargetVersion
        )
    }
}
