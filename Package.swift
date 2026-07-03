// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Anixart iOS — dependencies for the Xcode project.
// The main build uses `project.yml` (XcodeGen).
// This file is kept for SPM tooling compatibility.

import PackageDescription

let package = Package(
    name: "Anixart",
    platforms: [
        .iOS(.v17)
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "Anixart",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS"),
            ]
        ),
    ]
)
