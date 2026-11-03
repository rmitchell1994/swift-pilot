// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "swift-pilot",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "DurationKit", targets: ["DurationKit"]),
        .executable(name: "duration", targets: ["duration"]),
    ],
    targets: [
        .target(name: "DurationKit"),
        .executableTarget(name: "duration", dependencies: ["DurationKit"]),
        .testTarget(name: "DurationKitTests", dependencies: ["DurationKit"]),
    ]
)
