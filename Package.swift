// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PulseOrbs",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "ThinkingOrbs", targets: ["ThinkingOrbs"]),
        .executable(name: "PulseOrbsDemo", targets: ["PulseOrbsDemo"]),
    ],
    targets: [
        .target(name: "ThinkingOrbs"),
        .executableTarget(
            name: "PulseOrbsDemo",
            dependencies: ["ThinkingOrbs"]
        ),
        .testTarget(
            name: "ThinkingOrbsTests",
            dependencies: ["ThinkingOrbs"],
            resources: [.copy("Resources/orbs-golden.json")]
        ),
    ]
)
