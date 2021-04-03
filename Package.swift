// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImGuiDemo",
    platforms: [.macOS(.v10_14)],
    dependencies: [
        .package(url: "https://github.com/troughton/Substrate", from: "6.0.6"),
    ],
    targets: [
        .target(
            name: "ImGuiDemo",
            dependencies: ["AppFramework", "ShaderReflection"],
            linkerSettings: [.linkedFramework("AppKit", .when(platforms: [.macOS]))]),
        .target(name: "ShaderReflection", dependencies: [.product(name: "Substrate", package: "Substrate"), .product(name: "SubstrateMath", package: "Substrate")]),
        .testTarget(
            name: "ImGuiDemoTests",
            dependencies: ["ImGuiDemo"]),
    ]
)
