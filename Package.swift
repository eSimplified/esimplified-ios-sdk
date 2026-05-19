// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "EsimplifiedSDK",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "EsimplifiedSDK",
            targets: ["EsimplifiedSDK"]
        )
    ],
    targets: [
        .target(
            name: "EsimplifiedSDK",
            dependencies: [],
            path: "Sources/EsimplifiedSDK"
        ),
        .testTarget(
            name: "EsimplifiedSDKTests",
            dependencies: ["EsimplifiedSDK"],
            path: "Tests/EsimplifiedSDKTests"
        )
    ]
)
