// swift-tools-version: 6.2
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "fluent-gen",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "FluentGen",
            targets: ["FluentGen"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
    ],
    targets: [
        // Macro implementation (compiler plugin)
        .macro(
            name: "FluentGenMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        // Public API
        .target(
            name: "FluentGen",
            dependencies: [
                "FluentGenMacros",
                .product(name: "Fluent", package: "fluent"),
            ]
        ),

        // Tests
        .testTarget(
            name: "FluentGenTests",
            dependencies: [
                "FluentGen",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
