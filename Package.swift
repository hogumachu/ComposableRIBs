// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "ComposableRIBs",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "ComposableRIBs",
      targets: ["ComposableRIBs"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      exact: "1.23.1"
    )
  ],
  targets: [
    .target(
      name: "ComposableRIBsCore"
    ),
    .target(
      name: "ComposableRIBsTCA",
      dependencies: [
        "ComposableRIBsCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .target(
      name: "ComposableRIBsUI",
      dependencies: [
        "ComposableRIBsCore",
        "ComposableRIBsTCA",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .target(
      name: "ComposableRIBs",
      dependencies: [
        "ComposableRIBsCore",
        "ComposableRIBsTCA",
        "ComposableRIBsUI"
      ]
    ),
    .testTarget(
      name: "ComposableRIBsTests",
      dependencies: [
        "ComposableRIBs",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    )
  ]
)
