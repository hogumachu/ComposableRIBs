import ComposableRIBs

@MainActor
final class SearchLaunchRouter: UIKitLaunchRouter {
  init(searchBuilder: any SearchBuildable = SearchBuilder()) {
    let rootRouting = searchBuilder.build(with: SearchAppDependency())
    super.init(rootRouting: rootRouting)
  }
}
