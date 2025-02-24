// swift-tools-version:5.5  // Adding this line to specify Swift version
import PackageDescription

let package = Package(
    name: "WalkInMyShoes",
    products: [
        .library(
            name: "WalkInMyShoes",
            targets: ["WalkInMyShoes"]),
    ],
    dependencies: [  // Moving dependencies to package level
        .package(url: "https://github.com/samcool1224/Walk_In_My_Shoes.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "WalkInMyShoes",
            dependencies: ["WalkInMyShoes"],  // Adding dependencies to target
            path: ".",
            resources: [
                .process("Assets.xcassets"),  // Added missing comma
                .process("Fonts")
            ]
        ),
        .testTarget(
            name: "WalkInMyShoesTests",
            dependencies: ["WalkInMyShoes"]
        )
    ]
)
