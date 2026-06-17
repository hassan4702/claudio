// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Claudio",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "ClaudioCore", targets: ["ClaudioCore"]),
        .executable(name: "Claudio", targets: ["Claudio"]),
    ],
    targets: [
        .target(name: "ClaudioCore"),
        .executableTarget(name: "Claudio", dependencies: ["ClaudioCore"]),
        .testTarget(name: "ClaudioCoreTests", dependencies: ["ClaudioCore"]),
    ]
)
