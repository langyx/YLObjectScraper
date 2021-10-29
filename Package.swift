// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YLObjectScraper",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "YLObjectScraper",
            targets: ["YLObjectScraper"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "YLObjectScraper",
            dependencies: []),
        .testTarget(
            name: "YLObjectScraperTests",
            dependencies: ["YLObjectScraper"]),
    ]
)
