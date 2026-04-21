// swift-tools-version: 6.1

import PackageDescription

var package = Package(
    name: "NimbusAPSKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(
           name: "NimbusAPSKit",
           targets: ["NimbusAPSKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/adsbynimbus/swift-package-aps", from: "5.2.0"),
        .package(url: "https://github.com/birdrides/mockingbird", from: "0.20.0")
    ],
    targets: [
        .target(
            name: "NimbusAPSKit",
            dependencies: [
                .product(name: "NimbusKit", package: "nimbus-ios-sdk"),
                .product(name: "DTBiOSSDK", package: "swift-package-aps")
            ]
        ),
        .testTarget(
            name: "NimbusAPSKitTests",
            dependencies: [
                "NimbusAPSKit",
                .product(name: "Mockingbird", package: "mockingbird")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

package.dependencies.append(.package(url: "https://github.com/adsbynimbus/nimbus-ios-sdk", from: "3.0.0"))
