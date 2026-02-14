import UIKit

@MainActor
struct AppRootBuilder {
  func build() -> UIViewController {
    let router = ParentBuilder().build(with: SampleAppDependency(initialCounter: 1))
    let navigationController = UINavigationController(rootViewController: router.viewController)
    router.bind(navigationController: navigationController)
    router.interactor.activate()
    return navigationController
  }
}
