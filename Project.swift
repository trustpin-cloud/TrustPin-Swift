import ProjectDescription
import ProjectDescriptionHelpers

let libraryName: String = "TrustPinKit"

let version = Environment.Version.getString(default: "0.0.0")
let buildVersion = Environment.BuildVersion.getString(default: "0")

let libraryTarget = Target.libraryTarget(libraryName, version: version, buildVersion: buildVersion)
let testTarget = Target.libraryTestTarget(libraryName)
let testApp = Target.testApp(libraryName)

let project = Project(
    name: "TrustPin-Swift",
    organizationName: Constants.organizationName,
    options: Project.Options.options(automaticSchemesOptions: .disabled,
                                     disableBundleAccessors: false,
                                     disableSynthesizedResourceAccessors: true
    ),
    targets: [
        libraryTarget,
        testTarget,
        testApp
    ].compactMap { $0 },
    schemes: [
        .scheme(
            name: libraryName,
            shared: true,
            buildAction: BuildAction.buildAction(targets: [
                .target(libraryName),
                .target("\(libraryName)Tests"),
            ]),
            testAction: .testPlans(
                [
                    "\(libraryName)Tests.xctestplan",
                ]
            ),
            runAction: RunAction.runAction(configuration: .debug)
        ),
    ].compactMap { $0 }
)
