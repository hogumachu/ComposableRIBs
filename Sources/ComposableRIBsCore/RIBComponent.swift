/// Base dependency container that exposes only the contract needed by child modules.
open class RIBComponent<Dependency> {
  public let dependency: Dependency

  public init(dependency: Dependency) {
    self.dependency = dependency
  }
}
