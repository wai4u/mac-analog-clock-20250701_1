// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MyAnalogClock",
    platforms: [.macOS(.v14)], // Set the platform to macOS 14 or later
    products: [
        .executable(name: "MyAnalogClock", targets: ["MyAnalogClock"]),
    ],
    targets: [
        .executableTarget(
            name: "MyAnalogClock",
            dependencies: []),
    ]
)