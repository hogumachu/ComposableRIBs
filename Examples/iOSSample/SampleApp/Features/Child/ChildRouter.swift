import ComposableArchitecture
import ComposableRIBs
import UIKit

@MainActor
final class ChildRouter: SwiftUIHostingRouter<ChildFeature, ChildView>, ChildRouting {
  private let grandchildRouter: any GrandchildRouting
  private weak var navigationController: UINavigationController?
  private var isGrandchildAttached = false
  private var onCloseRequested: (() -> Void)?

  init(
    store: StoreOf<ChildFeature>,
    interactor: TCAInteractor<ChildFeature>,
    grandchildRouter: any GrandchildRouting
  ) {
    self.grandchildRouter = grandchildRouter
    super.init(store: store, interactor: interactor) {
      ChildView(store: store)
    }
  }

  func bind(
    navigationController: UINavigationController,
    onCloseRequested: @escaping () -> Void
  ) {
    self.navigationController = navigationController
    self.onCloseRequested = onCloseRequested
    grandchildRouter.bind(onCloseRequested: { [weak self] in
      self?.dismissGrandchildIfNeeded(animated: true)
    })
  }

  func detachGrandchildIfNeeded(animated: Bool) {
    dismissGrandchildIfNeeded(animated: animated)
  }

  override func bindState() {
    _ = tcaInteractor.observeDelegateEvents { [weak self] delegateEvent in
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
    attachActivateAndPush(grandchildRouter, in: navigationController, animated: animated)
    isGrandchildAttached = true
    _ = store.send(.grandchildPresentationChanged(true))
  }

  private func dismissGrandchildIfNeeded(animated: Bool) {
    guard let navigationController else { return }
    guard isGrandchildAttached else { return }
    deactivateDetachAndPop(
      grandchildRouter,
      in: navigationController,
      to: viewController,
      animated: animated
    )
    isGrandchildAttached = false
    _ = store.send(.grandchildPresentationChanged(false))
  }
}
