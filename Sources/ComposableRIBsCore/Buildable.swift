@MainActor
/// Constructs a routing tree by wiring dependencies and runtime collaborators.
///
/// Stability: stable-v0x
public protocol Buildable {
  associatedtype Dependency
  associatedtype BuildRouting: Routing

  /// Builds the module routing root using a dependency contract.
  func build(with dependency: Dependency) -> BuildRouting
}
