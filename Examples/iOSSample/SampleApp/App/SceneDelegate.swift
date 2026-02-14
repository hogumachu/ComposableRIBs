import ComposableRIBs
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  private var launchRouter: (any LaunchRouting)?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }

    let window = UIWindow(windowScene: windowScene)
    let launchRouter = AppRootBuilder().build()
    launchRouter.launch(from: window)
    self.window = window
    self.launchRouter = launchRouter
  }
}
