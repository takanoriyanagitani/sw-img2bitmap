// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "ImgToBmpToStdout",
  platforms: [
    .macOS(.v11)
  ],
  dependencies: [
    .package(url: "https://github.com/realm/SwiftLint", from: "0.58.2"),
    .package(path: "../.."),
  ],
  targets: [
    .executableTarget(
      name: "ImgToBmpToStdout",
      dependencies: [
        .product(name: "FpUtil", package: "sw-img2bitmap"),
        .product(name: "ImageToBitmap", package: "sw-img2bitmap"),
      ]
    )
  ]
)
