Pod::Spec.new do |spec|
  spec.name         = "TrustPinKit"
  spec.version      = "0.0.1"
  spec.summary      = "TrustPin iOS SDK for certificate pinning and security"
  spec.description  = <<-DESC
                    TrustPin provides advanced certificate pinning and network security
                    capabilities for iOS applications, ensuring secure communication
                    and protection against man-in-the-middle attacks.
                    DESC

  spec.homepage     = "https://github.com/trustpin-cloud/TrustPin-Swift"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "TrustPin" => "support@trustpin.cloud" }

  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "13.0"
  spec.watchos.deployment_target = "7.0"
  spec.tvos.deployment_target = "13.0"

  spec.source       = { :git => "https://github.com/trustpin-cloud/TrustPin-Swift.git", :tag => "v#{spec.version}" }
  spec.source_files = "Sources/TrustPinKit/**/*.swift"
  spec.resource_bundles = {
    'TrustPinKit_Privacy' => ['Sources/TrustPinKit/PrivacyInfo.xcprivacy']
  }

  spec.framework = "Foundation"
  spec.swift_version = "5.5"
end