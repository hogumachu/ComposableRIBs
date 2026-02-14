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
    let interactor: TCAInteractor<ParentFeature> = TCAInteractor(initialState: ParentFeature.State(counter: dependency.initialCounter)) {
      ParentFeature()
    }

    return ParentRouter(
      store: interactor.store,
      interactor: interactor,
      dependency: dependency,
      childBuilder: childBuilder
    )
  }
}
