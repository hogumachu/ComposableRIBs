import ComposableRIBsCore
import UIKit

/// UIKit launch coordinator that hosts a routable module in a navigation controller.
///
/// Stability: evolving-v0x
@MainActor
open class UIKitLaunchRouter: BaseLaunchRouter {
  public let rootRouting: any RoutableViewControlling
  public private(set) var navigationController: UINavigationController?

  public init(rootRouting: any RoutableViewControlling) {
    self.rootRouting = rootRouting
    super.init(rootRouter: rootRouting)
  }

  open override func attachRoot(to window: UIWindow) {
    let navigationController = UINavigationController(rootViewController: rootRouting.viewController)
    window.rootViewController = navigationController
    window.makeKeyAndVisible()
    self.navigationController = navigationController
  }

  open override func activateRoot() {
    rootRouting.interactor.activate()
  }
}
