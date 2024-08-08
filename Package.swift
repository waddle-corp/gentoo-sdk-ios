// swift-tools-version: 5.4
import PackageDescription

let package = Package(
    name: "GentooSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "GentooSDK",
            targets: ["GentooSDK"]),
    ],
    targets: [
        .target(
            name: "GentooSDK",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "GentooSDKTests",
            dependencies: ["GentooSDK"]
        ),
    ]
)
