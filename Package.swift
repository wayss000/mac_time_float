// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TimeFloat",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "TimeFloat", targets: ["TimeFloat"])],
    targets: [
        .target(name: "TimeFloatCore"),
        .executableTarget(name: "TimeFloat", dependencies: ["TimeFloatCore"]),
        .testTarget(name: "TimeFloatCoreTests", dependencies: ["TimeFloatCore"])
    ]
)
