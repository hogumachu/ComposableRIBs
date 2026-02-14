import UIKit

@MainActor
struct AppRootBuilder {
  private let parentBuilder: any ParentBuildable

  init(parentBuilder: any ParentBuildable = ParentBuilder()) {
    self.parentBuilder = parentBuilder
  }

  func build() -> UIViewController {
    let router = parentBuilder.build(with: SampleAppDependency(initialCounter: 1))
    let navigationController = UINavigationController(rootViewController: router.viewController)
    router.bind(navigationController: navigationController)
    router.interactor.activate()
    return navigationController
  }
}
