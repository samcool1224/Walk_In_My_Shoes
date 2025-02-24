// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WalkInMyShoes",
    products: [
        .library(
            name: "WalkInMyShoes",
            targets: ["WalkInMyShoes"]),
    ],
    dependencies: [
        .package(url: "https://github.com/samcool1224/Walk_In_My_Shoes.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "WalkInMyShoes",
            dependencies: ["WalkInMyShoes"],
            path: ".",
            resources: [
                .process("Assets.xcassets"),
                .process("Fonts")
            ]
        ),
        .testTarget(
            name: "WalkInMyShoesTests",
            dependencies: ["WalkInMyShoes"]
        )
    ]
)
