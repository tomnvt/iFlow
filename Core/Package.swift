// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v16),
        .macOS("14.0"),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Core",
            targets: ["Core"]
        ),
    ],
    dependencies: [
        .package(path: "../Controls"),
        .package(path: "../Midi"),
        .package(path: "../PianoRoll"),
        .package(path: "../PianoKeyboard"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Core",
            dependencies: [
                "Controls",
                "Midi",
                "PianoRoll",
                "PianoKeyboard",
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
        ),
    ]
)
