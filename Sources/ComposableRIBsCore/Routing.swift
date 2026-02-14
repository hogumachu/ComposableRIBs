/// Router contract for managing module tree composition.
public protocol Routing: AnyObject {
  /// Child routers currently attached to this router.
  var children: [any Routing] { get }

  /// Performs one-time router setup after construction.
  func load()
  /// Attaches a child router to the current router tree.
  func attachChild(_ child: any Routing)
  /// Detaches a previously attached child router.
  func detachChild(_ child: any Routing)
}

/// Default router implementation with child attachment safety.
open class BaseRouter: Routing {
  public private(set) var children: [any Routing] = []

  public init() {}

  open func load() {}

  open func attachChild(_ child: any Routing) {
    // Object identity ensures the same router instance is attached at most once.
    guard !children.contains(where: { ObjectIdentifier($0) == ObjectIdentifier(child) }) else {
      return
    }
    children.append(child)
  }

  open func detachChild(_ child: any Routing) {
    // Remove every matching reference in case manual mutations introduced duplicates.
    children.removeAll { ObjectIdentifier($0) == ObjectIdentifier(child) }
  }
}
