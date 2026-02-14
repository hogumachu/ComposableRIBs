import ComposableArchitecture
import ComposableRIBs

@MainActor
struct ParentBuilder: Buildable {
  private let childBuilder = ChildBuilder()

  func build(with dependency: any ParentDependency) -> ParentRouter {
    let childDependency = ParentComponent(dependency: dependency)
    let child = childBuilder.build(with: childDependency)

    let store = Store(initialState: ParentFeature.State(counter: dependency.initialCounter)) {
      ParentFeature()
    }
    let interactor = TCAInteractor<ParentFeature>(store: store)

    return ParentRouter(store: store, interactor: interactor, childRouter: child)
  }
}
