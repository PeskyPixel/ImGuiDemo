// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImGuiDemo",
    platforms: [.macOS(.v11), .iOS(.v14), .tvOS(.v14)],
    dependencies: [
        .package(name: "Substrate", url: "https://github.com/troughton/SubstrateRender", from: "8.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "ImGuiDemo",
            dependencies: [.product(name: "AppFramework", package: "Substrate"), "ShaderReflection"],
            linkerSettings: [.linkedFramework("AppKit", .when(platforms: [.macOS]))]),
        .target(name: "ShaderReflection", dependencies: [.product(name: "Substrate", package: "Substrate"), .product(name: "SubstrateMath", package: "Substrate")]),
        .testTarget(
            name: "ImGuiDemoTests",
            dependencies: ["ImGuiDemo"]),
    ]
)
