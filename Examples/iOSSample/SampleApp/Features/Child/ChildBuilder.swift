import ComposableArchitecture
import ComposableRIBs

@MainActor
struct ChildBuilder: Buildable {
  private let grandchildBuilder = GrandchildBuilder()

  func build(with dependency: any ChildDependency) -> ChildRouter {
    let grandchildDependency = ChildComponent(dependency: dependency)
    let grandchild = grandchildBuilder.build(with: grandchildDependency)

    let store = Store(initialState: ChildFeature.State(seedValue: dependency.childSeedValue)) {
      ChildFeature()
    }
    let interactor = TCAInteractor<ChildFeature>(store: store)

    return ChildRouter(store: store, interactor: interactor, grandchildRouter: grandchild)
  }
}
