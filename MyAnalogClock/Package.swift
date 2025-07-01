// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MyAnalogClock",
    platforms: [.macOS(.v11)], // Set the platform to macOS 11 or later
    products: [
        .executable(name: "MyAnalogClock", targets: ["MyAnalogClock"]),
    ],
    targets: [
        .executableTarget(
            name: "MyAnalogClock",
            dependencies: []),
    ]
)