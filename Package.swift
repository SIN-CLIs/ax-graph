// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ax-graph",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ax-graph", targets: ["ax-graph"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-crypto", from: "3.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ax-graph",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Crypto", package: "swift-crypto")
            ],
            path: "Sources/ax-graph"
        )
    ]
)
