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

    let store = Store(initialState: ParentFeature.State(counter: dependency.initialCounter)) {
      ParentFeature()
    }
    let interactor = TCAInteractor<ParentFeature>(store: store)

    return ParentRouter(store: store, interactor: interactor, childRouter: child)
  }
}
