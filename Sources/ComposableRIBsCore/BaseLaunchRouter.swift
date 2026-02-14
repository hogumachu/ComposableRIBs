import UIKit

/// Base app-launch coordinator that owns the root router lifecycle.
///
/// Stability: evolving-v0x
@MainActor
open class BaseLaunchRouter: LaunchRouting {
  public let rootRouter: any Routing

  public init(rootRouter: any Routing) {
    self.rootRouter = rootRouter
  }

  /// Hook for subclasses to attach root UI into the launch window.
  open func attachRoot(to window: UIWindow) {
    _ = window
  }

  /// Hook for subclasses to activate runtime lifecycle after root attachment.
  open func activateRoot() {}

  open func launch(from window: UIWindow) {
    rootRouter.load()
    attachRoot(to: window)
    activateRoot()
  }
}
