// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let keychainWrapper: String = "SecretInfoKeyChain"
let keychainWrapperRxSwift: String = "\(keychainWrapper)RxSwift"
let keychainWrapperCombine: String = "\(keychainWrapper)Combine"
let keychainWrapperSwift: String = "\(keychainWrapper)Swift"

let package = Package(
    name: keychainWrapper,
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: keychainWrapper,
            targets: [keychainWrapper]),
        .library(
            name: keychainWrapperCombine,
            targets: [keychainWrapperCombine]),
        .library(
            name: keychainWrapperSwift,
            targets: [keychainWrapperSwift]),
        .library(
            name: keychainWrapperRxSwift,
            targets: [keychainWrapperRxSwift])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.0.0")
    ],
    targets: [
        .target(
            name: keychainWrapper,
            dependencies: []),
        .target(
            name: keychainWrapperCombine,
            dependencies: [.init(stringLiteral: keychainWrapper)]),
        .target(
            name: keychainWrapperSwift,
            dependencies: [.init(stringLiteral: keychainWrapper)]),
        .target(
            name: keychainWrapperRxSwift,
            dependencies: [
                .init(stringLiteral: keychainWrapper),
                .product(name: "RxSwift", package: "RxSwift")]),
        .testTarget(
            name: "KeyChainWrapperTests",
            dependencies: [
                .init(stringLiteral: keychainWrapper),
                .init(stringLiteral: keychainWrapperSwift)]),
        .testTarget(
            name: "KeyChainWrapperCombineTests",
            dependencies: [.init(stringLiteral: keychainWrapperCombine)]),
        .testTarget(
            name: "KeyChainWrapperRxTests",
            dependencies: [
                .product(name: "RxBlocking", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift"),
                .init(stringLiteral: keychainWrapperRxSwift),
            ]),
    ]
)
