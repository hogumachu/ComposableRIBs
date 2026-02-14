import ComposableArchitecture
import ComposableRIBs

@MainActor
protocol GrandchildRouting: RoutableViewControlling {
  func bind(onCloseRequested: @escaping () -> Void)
}

@MainActor
protocol GrandchildBuildable {
  func build(with dependency: any GrandchildDependency) -> any GrandchildRouting
}

@MainActor
struct GrandchildBuilder: GrandchildBuildable {
  func build(with dependency: any GrandchildDependency) -> any GrandchildRouting {
    let store = Store(initialState: GrandchildFeature.State(title: dependency.grandchildTitle)) {
      GrandchildFeature()
    }
    let interactor = TCAInteractor<GrandchildFeature>(store: store)
    return GrandchildRouter(store: store, interactor: interactor)
  }
}
