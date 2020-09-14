// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "CLKit",
    products: [
        .library(
            name: "CLKit",
            targets: ["CLKit"]),
    ],
    targets: [
        .target(
            name: "CLKit",
            dependencies: []),
        .testTarget(
            name: "CLKitTests",
            dependencies: ["CLKit"]),
    ]
)
