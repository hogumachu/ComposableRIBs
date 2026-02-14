// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "ComposableRIBs",
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
      name: "ComposableRIBs",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
  ]
)
