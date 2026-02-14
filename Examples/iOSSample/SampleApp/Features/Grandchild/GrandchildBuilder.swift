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
    let interactor = TCAInteractor<GrandchildFeature>(
      initialState: GrandchildFeature.State(title: dependency.grandchildTitle),
      reducer: { GrandchildFeature() }
    )
    return GrandchildRouter(store: interactor.store, interactor: interactor)
  }
}
