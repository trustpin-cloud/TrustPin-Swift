import Foundation
import ProjectDescription

public extension Settings {
    static func librarySettings(organizationName: String,
                                developmentTeam: String,
                                swiftVersion: String = "5.9",
                                version: String,
                                buildVersion: String) -> Settings {
        var base: SettingsDictionary = [
            "DEAD_CODE_STRIPPING": true,
            "GENERATE_INFOPLIST_FILE": true,
            "BUILD_LIBRARY_FOR_DISTRIBUTION": true,
            "SWIFT_SERIALIZE_DEBUGGING_OPTIONS": false,
            "DISABLE_DIAMOND_PROBLEM_DIAGNOSTIC": true,
            "OTHER_LDFLAGS": .array(["$(inherited)", "-ObjC"]),
            "DEVELOPMENT_TEAM": .string(developmentTeam),
            "ENABLE_TESTABILITY": true,
        ]
        base = base.codeSignIdentityAppleDevelopment()
            .automaticCodeSigning(devTeam: developmentTeam)
            .debugInformationFormat(.dwarfWithDsym)
            .swiftOptimizationLevel(.oNone)
            .swiftCompilationMode(.singlefile)
            .swiftVersion(swiftVersion)
            .marketingVersion(version)
            .currentProjectVersion(buildVersion)
            .bitcodeEnabled(false)
            .otherSwiftFlags(["$(inherited)", "-Xfrontend -no-serialize-debugging-options"])

        var release = base
        release = release.manualCodeSigning(identity: "Apple Distribution: \(organizationName)")
            .swiftOptimizationLevel(.oSize)
            .swiftCompilationMode(.wholemodule)

        return Settings.settings(base: base, debug: base, release: release, defaultSettings: .recommended)
    }

    static func testSettings(organizationName: String,
                             developmentTeam: String,
                             swiftVersion: String = "5.9",
                             version: String,
                             buildVersion: String) -> Settings {
        var base: SettingsDictionary = [
            "DEAD_CODE_STRIPPING": true,
            "GENERATE_INFOPLIST_FILE": true,
            "BUILD_LIBRARY_FOR_DISTRIBUTION": true,
            "SWIFT_SERIALIZE_DEBUGGING_OPTIONS": false,
            "DISABLE_DIAMOND_PROBLEM_DIAGNOSTIC": true,
            "OTHER_LDFLAGS": .array(["$(inherited)", "-ObjC"]),
            "DEVELOPMENT_TEAM": .string(developmentTeam),
            "ENABLE_TESTABILITY": true
        ]
        base = base.codeSignIdentityAppleDevelopment()
            .automaticCodeSigning(devTeam: developmentTeam)
            .debugInformationFormat(.dwarfWithDsym)
            .swiftOptimizationLevel(.oNone)
            .swiftCompilationMode(.singlefile)
            .swiftVersion(swiftVersion)
            .marketingVersion(version)
            .currentProjectVersion(buildVersion)
            .bitcodeEnabled(false)
            .otherSwiftFlags(["$(inherited)", "-Xfrontend -no-serialize-debugging-options"])

        return Settings.settings(base: base, debug: base, release: base, defaultSettings: .recommended)
    }

    static func sampleAppSettings(organizationName: String,
                                  developmentTeam: String,
                                  swiftVersion: String = "5.9",
                                  version: String,
                                  buildVersion: String) -> Settings {
        var base: SettingsDictionary = [
            "DEAD_CODE_STRIPPING": true,
            "GENERATE_INFOPLIST_FILE": true,
            "BUILD_LIBRARY_FOR_DISTRIBUTION": true,
            "SWIFT_SERIALIZE_DEBUGGING_OPTIONS": false,
            "ENABLE_MODULE_VERIFIER": true,
            "MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS": .string("gnu11 gnu++14"),
            "MODULE_VERIFIER_SUPPORTED_LANGUAGES": .string("objective-c objective-c++"),
            "DISABLE_DIAMOND_PROBLEM_DIAGNOSTIC": true,
            "OTHER_LDFLAGS": .array(["$(inherited)", "-ObjC"]),
            "DEVELOPMENT_TEAM": .string(developmentTeam),
            "ENABLE_TESTABILITY": true,
            "UILaunchStoryboardName": .string("LaunchScreen"),
        ]
        base = base.codeSignIdentityAppleDevelopment()
            .automaticCodeSigning(devTeam: developmentTeam)
            .debugInformationFormat(.dwarfWithDsym)
            .swiftOptimizationLevel(.oNone)
            .swiftCompilationMode(.singlefile)
            .swiftVersion(swiftVersion)
            .marketingVersion(version)
            .currentProjectVersion(buildVersion)

        var release = base
        release = release.manualCodeSigning(identity: "Apple Distribution: \(organizationName)")
            .swiftOptimizationLevel(.oSize)
            .swiftCompilationMode(.wholemodule)

        return Settings.settings(base: base, debug: base, release: release, defaultSettings: .recommended)
    }
}
