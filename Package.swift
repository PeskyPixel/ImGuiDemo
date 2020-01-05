// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImGuiDemo",
    platforms: [.macOS(.v10_14)],
    dependencies: [
        .package(url: "https://github.com/troughton/AppFramework", .branch("master")),
        .package(url: "https://github.com/troughton/SwiftFrameGraph", .branch("master")),
        .package(url: "https://github.com/troughton/SwiftMath", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "ImGuiDemo",
            dependencies: ["AppFramework", "ShaderReflection"],
            linkerSettings: [.linkedFramework("AppKit")]),
        .target(name: "ShaderReflection", dependencies: ["SwiftFrameGraph", "SwiftMath"]),
        .testTarget(
            name: "ImGuiDemoTests",
            dependencies: ["ImGuiDemo"]),
    ]
)
