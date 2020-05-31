// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "CommandLineKit",
    products: [
        .library(
            name: "CommandLineKit",
            targets: ["CommandLineKit"]),
    ],
    targets: [
        .target(
            name: "CommandLineKit",
            dependencies: []),
        .testTarget(
            name: "CommandLineKitTests",
            dependencies: ["CommandLineKit"]),
    ]
)
