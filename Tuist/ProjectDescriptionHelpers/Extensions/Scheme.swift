import ProjectDescription

public extension Scheme {
    static func sampleAppScheme(for target: Target? = nil) -> Scheme? {
        if Environment.isCI.getBoolean(default: false) {
            return nil // No Sample Apps on CI until we have provisioning profiles
        }
        guard let target else {
            return nil
        }
        return Scheme.scheme(
            name: target.name,
            shared: false,
            buildAction: BuildAction.buildAction(targets: [
                .target(target.name),
            ]),
            runAction: RunAction.runAction(configuration: .debug)
        )
    }
}
