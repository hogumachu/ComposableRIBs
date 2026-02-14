import ComposableArchitecture
import ComposableRIBs
import UIKit

@MainActor
protocol ChildRouting: RoutableViewControlling {
  func bind(
    navigationController: UINavigationController,
    onCloseRequested: @escaping () -> Void
  )

  func detachGrandchildIfNeeded(animated: Bool)
}

@MainActor
protocol ChildBuildable {
  func build(with dependency: any ChildDependency) -> any ChildRouting
}

@MainActor
struct ChildBuilder: ChildBuildable {
  private let grandchildBuilder: any GrandchildBuildable

  init(grandchildBuilder: any GrandchildBuildable = GrandchildBuilder()) {
    self.grandchildBuilder = grandchildBuilder
  }

  func build(with dependency: any ChildDependency) -> any ChildRouting {
    let grandchildDependency = ChildComponent(dependency: dependency)
    let grandchild = grandchildBuilder.build(with: grandchildDependency)

    let actionRelay = ActionRelay<ChildFeature.Action>()
    let store = Store(initialState: ChildFeature.State(seedValue: dependency.childSeedValue)) {
      ActionObservingReducer(base: ChildFeature()) { action in
        actionRelay.emit(action)
      }
    }
    let interactor = TCAInteractor<ChildFeature>(store: store, actionRelay: actionRelay)

    return ChildRouter(store: store, interactor: interactor, grandchildRouter: grandchild)
  }
}
