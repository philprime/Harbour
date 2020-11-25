// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Harbour",
    products: [
        .library(name: "Harbour", targets: ["Harbour"]),
    ],
    dependencies: [
        .package(url: "https://github.com/philprime/Cabinet", .upToNextMajor(from: "0.1.0")),
        .package(url: "https://github.com/Quick/Quick", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/Quick/Nimble", .upToNextMajor(from: "8.0.7"))
    ],
    targets: [
        .target(name: "Harbour", dependencies: [
            "Cabinet"
        ]),
        .testTarget(name: "HarbourTests", dependencies: [
            "Harbour",
            "Quick",
            "Nimble"
        ]),
    ]
)
