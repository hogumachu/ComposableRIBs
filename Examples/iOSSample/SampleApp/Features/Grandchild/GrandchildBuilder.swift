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
    let actionRelay = ActionRelay<GrandchildFeature.Action>()
    let store = Store(initialState: GrandchildFeature.State(title: dependency.grandchildTitle)) {
      ActionObservingReducer(base: GrandchildFeature()) { action in
        actionRelay.emit(action)
      }
    }
    let interactor = TCAInteractor<GrandchildFeature>(store: store, actionRelay: actionRelay)
    return GrandchildRouter(store: store, interactor: interactor)
  }
}
