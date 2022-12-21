// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SecretInfoKeyChain",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "SecretInfoKeyChain",
            targets: ["KeyChainWrapper"]),
        .library(
            name: "SecretInfoKeyChainCombine",
            targets: ["KeyChainWrapperCombine"]),
        .library(
            name: "SecretInfoKeyChainSwift",
            targets: ["KeyChainWrapperSwift"]),
        .library(
            name: "SecretInfoKeyChainRxSwift",
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
            dependencies: [
                "KeyChainWrapper",
                .product(name: "RxSwift", package: "RxSwift")]),
        .testTarget(
            name: "KeyChainWrapperTests",
            dependencies: ["KeyChainWrapper", "KeyChainWrapperSwift"]),
        .testTarget(
            name: "KeyChainWrapperCombineTests",
            dependencies: ["KeyChainWrapperCombine"]),
        .testTarget(
            name: "KeyChainWrapperRxTests",
            dependencies: [
                .product(name: "RxBlocking", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift"),
                "KeyChainWrapperRxSwift",
            ]),
    ]
)
