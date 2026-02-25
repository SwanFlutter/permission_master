// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "permission_master",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "permission-master", targets: ["permission_master"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "permission_master",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
   )
    ]
)