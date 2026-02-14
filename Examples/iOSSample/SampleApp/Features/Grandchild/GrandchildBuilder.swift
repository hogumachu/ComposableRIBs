import ComposableArchitecture
import ComposableRIBs

@MainActor
struct GrandchildBuilder: Buildable {
  func build(with dependency: any GrandchildDependency) -> GrandchildRouter {
    let store = Store(initialState: GrandchildFeature.State(title: dependency.grandchildTitle)) {
      GrandchildFeature()
    }
    let interactor = TCAInteractor<GrandchildFeature>(store: store)
    return GrandchildRouter(store: store, interactor: interactor)
  }
}
