import ComposableRIBs

@MainActor
struct AppRootBuilder {
  private let launchRouterFactory: () -> any LaunchRouting

  init(launchRouterFactory: @escaping () -> any LaunchRouting = { SampleLaunchRouter() }) {
    self.launchRouterFactory = launchRouterFactory
  }

  /// Builds the app launch coordinator used by SceneDelegate.
  func build() -> any LaunchRouting {
    launchRouterFactory()
  }
}
