// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KeyChainWrapper",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "KeyChainWrapper",
            targets: ["KeyChainWrapper"]),
        .library(
            name: "KeyChainWrapperCombine",
            targets: ["KeyChainWrapperCombine"]),
        .library(
            name: "KeyChainWrapperSwift",
            targets: ["KeyChainWrapperSwift"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "KeyChainWrapper",
            dependencies: []),
        .target(
            name: "KeyChainWrapperCombine",
            dependencies: ["KeyChainWrapper"]),
        .target(
            name: "KeyChainWrapperSwift",
            dependencies: ["KeyChainWrapper"]),
        .testTarget(
            name: "KeyChainWrapperTests",
            dependencies: ["KeyChainWrapper", "KeyChainWrapperSwift"]),
        .testTarget(
            name: "KeyChainWrapperCombineTests",
            dependencies: ["KeyChainWrapperCombine", "KeyChainWrapperSwift"]),
    ]
)
