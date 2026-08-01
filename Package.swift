// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarstekMacWidget",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "MarstekMacWidget", targets: ["MarstekMacWidget"])],
    targets: [
        .target(name: "MarstekCore"),
        .executableTarget(name: "MarstekMacWidget", dependencies: ["MarstekCore"]),
        .testTarget(name: "MarstekCoreTests", dependencies: ["MarstekCore"])
    ]
)
