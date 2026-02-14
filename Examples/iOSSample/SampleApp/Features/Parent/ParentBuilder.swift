import ComposableArchitecture
import ComposableRIBs
import UIKit

@MainActor
protocol ParentRouting: RoutableViewControlling {
  func bind(navigationController: UINavigationController)
}

@MainActor
protocol ParentBuildable {
  func build(with dependency: any ParentDependency) -> any ParentRouting
}

@MainActor
struct ParentBuilder: ParentBuildable {
  private let childBuilder: any ChildBuildable

  init(childBuilder: any ChildBuildable = ChildBuilder()) {
    self.childBuilder = childBuilder
  }

  func build(with dependency: any ParentDependency) -> any ParentRouting {
    let childDependency = ParentComponent(dependency: dependency)
    let child = childBuilder.build(with: childDependency)

    let actionRelay = ActionRelay<ParentFeature.Action>()
    let store = Store(initialState: ParentFeature.State(counter: dependency.initialCounter)) {
      ActionObservingReducer(base: ParentFeature()) { action in
        actionRelay.emit(action)
      }
    }
    let interactor = TCAInteractor<ParentFeature>(store: store, actionRelay: actionRelay)

    return ParentRouter(store: store, interactor: interactor, childRouter: child)
  }
}
