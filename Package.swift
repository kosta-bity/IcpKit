// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IcpKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "IcpKit", targets: ["IcpKit"]),
        .library(name: "Candid", targets: ["Candid"]),
        .executable(name: "CodeGenerator", targets: ["CodeGenerator"]),
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
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ], 
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "IcpKit",
            dependencies: [
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
            name: "Candid",
            dependencies: [
                "PotentCodables",
                .product(name: "Base32", package: "Bases"),
            ]
        ),
        .executableTarget(
            name: "CodeGenerator",
            dependencies: [
                "Candid",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
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
            dependencies: ["Candid"]
        ),
        .testTarget(
            name: "CodeGeneratorTests",
            dependencies: ["CodeGenerator", "Candid"],
            resources: [
                .process("DidFiles/ICRC7.did"),
                .process("DidFiles/GoldNFT.did"),
                .process("DidFiles/EVMProviders.did"),
                .process("DidFiles/LedgerCanister.did"),
                .process("DidFiles/TestImports.did"),
                .process("DidFiles/TestImports2.did"),
                .process("Generated/LedgerCanister.generated_swift"),
                .process("Generated/ICRC7.generated_swift"),
                .process("Generated/GoldNFT.generated_swift"),
                .process("Generated/TestCodeGeneration.generated_swift"),
                .process("Generated/TestImports.generated_swift"),
                .process("Generated/EVMProviders.generated_swift"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
