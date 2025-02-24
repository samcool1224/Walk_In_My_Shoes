// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WalkInMyShoes",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WalkInMyShoes",
            targets: ["WalkInMyShoes"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WalkInMyShoes",
            path: ".",
            resources: [
                .process("Assets.xcaassets")
                .process("Fonts")
                ],)
        dependencies: [.package(url: "https://github.com/samcool1224/Walk_In_My_Shoes.git", from: "1.0.0")]
        .testTarget(
            name: "WalkInMyShoesTests",
            dependencies: ["WalkInMyShoes"]
        ),
    ]
)
