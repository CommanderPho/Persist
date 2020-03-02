// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Persist",
    products: [
        .library(name: "Persist", targets: ["Persist"]),
    ],
    targets: [
        .target(name: "Persist"),
        .testTarget(name: "PersistTests", dependencies: ["Persist"]),
    ]
)
