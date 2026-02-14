/// Base dependency container that exposes only the contract needed by child modules.
///
/// Stability: stable-v0x
public class RIBComponent<Dependency> {
  public let dependency: Dependency

  public init(dependency: Dependency) {
    self.dependency = dependency
  }
}
