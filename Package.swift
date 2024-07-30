// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IcpKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v11)
    ], 
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "IcpKit", targets: ["IcpKit"]),
        .library(name: "Candid", targets: ["Candid"]),
        //.library(name: "Bls12381", targets: ["bls12381"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMajor(from: "5.3.0")),
        .package(url: "https://github.com/outfoxx/PotentCodables.git", .upToNextMajor(from: "3.2.0")),
        .package(url: "https://github.com/immobiliare/RealHTTP.git", .upToNextMajor(from: "1.8.3")),
        .package(url: "https://github.com/mattrubin/Bases", branch: "develop"),
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift.git", exact: "0.10.0"),
        .package(url: "https://github.com/horizontalsystems/HsCryptoKit.Swift.git", .upToNextMajor(from: "1.2.1")),
        
    ], 
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "IcpKit",
            dependencies: [
                "Utils",
                "Candid",
                "BigInt",
                "RealHTTP",
                .product(name: "secp256k1", package: "secp256k1.swift"),
                .product(name: "HsCryptoKit", package: "HsCryptoKit.Swift"),
//                .target(name: "bls12381"),
            ]
//            cSettings: [.headerSearchPath("Sources/bls12381/include"),
//                        .unsafeFlags(["-ISources/bls12381/include/Bls12381.h"])],
//            cxxSettings: [.headerSearchPath("Sources/bls12381/include"),
//                          .unsafeFlags(["-ISources/bls12381/include/Bls12381.h"])]
        ),
        .target(
            name: "Utils",
            dependencies: [
                .product(name: "Base32", package: "Bases"),
            ]
        ),
        .target(
            name: "Candid",
            dependencies: ["Utils", "PotentCodables",]
        ),
//        .binaryTarget(
//            name: "bls12381",
//            path: "Binaries/Bls12381.xcframework"
//        ),
        .testTarget(
            name: "IcpKitTests",
            dependencies: ["IcpKit",]
        ),
        .testTarget(
            name: "CandidTests",
            dependencies: ["Candid",],
            resources: [
                .process("DidFiles/ICRC7.did"),
                .process("DidFiles/GoldNFT.did")
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
