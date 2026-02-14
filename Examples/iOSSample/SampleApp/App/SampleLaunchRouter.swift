import ComposableRIBs
import UIKit

@MainActor
final class SampleLaunchRouter: UIKitLaunchRouter {
  private let parentRouting: any ParentRouting

  init(parentBuilder: any ParentBuildable = ParentBuilder()) {
    let parentRouting = parentBuilder.build(with: SampleAppDependency(initialCounter: 1))
    self.parentRouting = parentRouting
    super.init(rootRouting: parentRouting)
  }

  override func attachRoot(to window: UIWindow) {
    super.attachRoot(to: window)
    guard let navigationController else { return }
    parentRouting.bind(navigationController: navigationController)
  }
}
