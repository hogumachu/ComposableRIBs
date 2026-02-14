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
    let interactor: TCAInteractor<ChildFeature> = TCAInteractor(initialState: ChildFeature.State(seedValue: dependency.childSeedValue)) {
      ChildFeature()
    }

    return ChildRouter(
      interactor: interactor,
      dependency: dependency,
      grandchildBuilder: grandchildBuilder
    )
  }
}
