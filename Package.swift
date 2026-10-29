// swift-tools-version: 6.1

import PackageDescription

var package = Package(
    name: "NimbusAPSKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(
           name: "NimbusAPSKit",
           targets: ["NimbusAPSKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/amzn/swift-package-manager-amazon-aps", from: "5.6.6")
    ],
    targets: [
        .target(
            name: "NimbusAPSKit",
            dependencies: [
                .product(name: "NimbusKit", package: "nimbus-ios-sdk"),
                .product(name: "AmazonPublisherServicesSDK", package: "swift-package-manager-amazon-aps")
            ]
        ),
        .testTarget(
            name: "NimbusAPSKitTests",
            dependencies: ["NimbusAPSKit"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

package.dependencies.append(.package(url: "https://github.com/adsbynimbus/nimbus-ios-sdk", from: "3.0.0"))
