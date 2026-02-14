import ComposableArchitecture
import ComposableRIBs
import UIKit

@MainActor
final class ChildRouter: SwiftUIHostingRouter<ChildFeature, ChildView>, ChildRouting {
  private let dependency: any ChildDependency
  private let grandchildBuilder: any GrandchildBuildable
  private var grandchildRouter: (any GrandchildRouting)?
  private weak var navigationController: UINavigationController?
  private var isGrandchildAttached = false
  private var onCloseRequested: (() -> Void)?

  init(
    interactor: TCAInteractor<ChildFeature>,
    dependency: any ChildDependency,
    grandchildBuilder: any GrandchildBuildable
  ) {
    self.dependency = dependency
    self.grandchildBuilder = grandchildBuilder
    super.init(interactor: interactor) {
      ChildView(store: interactor.store)
    }
  }

  func bind(
    navigationController: UINavigationController,
    onCloseRequested: @escaping () -> Void
  ) {
    self.navigationController = navigationController
    self.onCloseRequested = onCloseRequested
  }

  func detachGrandchildIfNeeded(animated: Bool) {
    dismissGrandchildIfNeeded(animated: animated)
  }

  override func bindState() {
    _ = tcaInteractor.observeDelegateEvents(for: \.delegate) { [weak self] delegateEvent in
      guard let self else { return }
      switch delegateEvent {
      case .showGrandchildRequested:
        self.presentGrandchildIfNeeded(animated: true)
      case .closeRequested:
        self.onCloseRequested?()
      }
    }
  }

  private func presentGrandchildIfNeeded(animated: Bool) {
    guard let navigationController else { return }
    guard !isGrandchildAttached else { return }
    guard grandchildRouter == nil else { return }
    let grandchildDependency = ChildComponent(dependency: dependency)
    let grandchildRouter = grandchildBuilder.build(with: grandchildDependency)
    grandchildRouter.bind(onCloseRequested: { [weak self] in
      self?.dismissGrandchildIfNeeded(animated: true)
    })
    self.grandchildRouter = grandchildRouter
    attachActivateAndPush(grandchildRouter, in: navigationController, animated: animated)
    isGrandchildAttached = true
    _ = store.send(.grandchildPresentationChanged(true))
  }

  private func dismissGrandchildIfNeeded(animated: Bool) {
    guard let navigationController else { return }
    guard let grandchildRouter else { return }
    guard isGrandchildAttached else { return }
    deactivateDetachAndPop(
      grandchildRouter,
      in: navigationController,
      to: viewController,
      animated: animated
    )
    isGrandchildAttached = false
    self.grandchildRouter = nil
    _ = store.send(.grandchildPresentationChanged(false))
  }

}
