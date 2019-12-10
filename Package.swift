// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SwiftMetal",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
    ],
    products: [
        .library(name: "SwiftMetal", targets: ["SwiftMetal"]),
    ],
    targets: [
        .target(name: "SwiftMetal", path: "Sources"),
        .testTarget(name: "SwiftMetalTests", dependencies: ["SwiftMetal"], path: "SwiftMetalTests"),
    ]
)
