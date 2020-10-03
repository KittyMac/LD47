// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "LD47",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(name: "LD47", targets: ["LD47"]),
        .library(name: "LD47Framework", targets: ["LD47Framework"])
    ],
    dependencies: [
		.package(url: "https://github.com/KittyMac/Flynn.git", .branch("master")),
		.package(url: "https://github.com/KittyMac/Picaroon.git", .branch("master")),
		.package(url: "https://github.com/KittyMac/Ipecac.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "LD47",
            dependencies: [
                "LD47Framework",
            ]
        ),
        .target(
            name: "LD47Framework",
            dependencies: [
                "Ipecac",
                "Flynn",
				"Pamphlet",
				.product(name: "PicaroonFramework", package: "Picaroon"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "Pamphlet"
        ),
        .testTarget(
            name: "LD47FrameworkTests",
            dependencies: [
                "LD47Framework"
            ],
            exclude: [
                "Resources"
            ]
        )
    ]
)
