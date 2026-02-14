import ComposableRIBs

@MainActor
struct AppRootBuilder {
  private let launchRouterFactory: () -> any LaunchRouting

  init(launchRouterFactory: @escaping () -> any LaunchRouting = { SearchLaunchRouter() }) {
    self.launchRouterFactory = launchRouterFactory
  }

  func build() -> any LaunchRouting {
    launchRouterFactory()
  }
}
