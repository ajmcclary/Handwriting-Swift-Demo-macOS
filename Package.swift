// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "HandwritingApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "HandwritingApp", targets: ["HandwritingApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "HandwritingApp",
            path: "HandwritingApp",
            resources: [
                .copy("Resources/TrOCR-Handwritten.mlmodelc")
            ]
        )
    ]
)
