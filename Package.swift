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
            targets: ["KeyChainWrapperSwift"]),
        .library(
            name: "KeyChainWrapperRxSwift",
            targets: ["KeyChainWrapperRxSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.0.0")
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
        .target(
            name: "KeyChainWrapperRxSwift",
            dependencies: ["KeyChainWrapper", "RxSwift"]),
        .testTarget(
            name: "KeyChainWrapperTests",
            dependencies: ["KeyChainWrapper", "KeyChainWrapperSwift"]),
        .testTarget(
            name: "KeyChainWrapperCombineTests",
            dependencies: ["KeyChainWrapperCombine", "KeyChainWrapperSwift"]),
    ]
)
