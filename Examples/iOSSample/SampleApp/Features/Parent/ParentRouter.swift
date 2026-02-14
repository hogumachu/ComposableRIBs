import ComposableArchitecture
import ComposableRIBs
import UIKit

@MainActor
final class ParentRouter: SwiftUIHostingRouter<ParentFeature, ParentView>, ParentRouting {
  private let childRouter: any ChildRouting
  private weak var navigationController: UINavigationController?
  private var isChildAttached = false

  init(
    store: StoreOf<ParentFeature>,
    interactor: TCAInteractor<ParentFeature>,
    childRouter: any ChildRouting
  ) {
    self.childRouter = childRouter
    super.init(store: store, interactor: interactor) {
      ParentView(store: store)
    }
  }

  func bind(navigationController: UINavigationController) {
    self.navigationController = navigationController
    childRouter.bind(navigationController: navigationController, onCloseRequested: { [weak self] in
      self?.dismissChildIfNeeded(animated: true)
    })
  }

  override func bindState() {
    // Upstream navigation intent is delegate-first. Router maps delegate actions to UIKit transitions.
    _ = tcaInteractor.observeDelegateEvents(for: \.delegate) { [weak self] delegateEvent in
      guard let self else { return }
      switch delegateEvent {
      case .showChildRequested:
        self.presentChildIfNeeded(animated: true)
      }
    }
  }

  private func presentChildIfNeeded(animated: Bool) {
    guard let navigationController else { return }
    guard !isChildAttached else { return }
    attachActivateAndPush(childRouter, in: navigationController, animated: animated)
    isChildAttached = true
    _ = store.send(.childPresentationChanged(true))
  }

  private func dismissChildIfNeeded(animated: Bool) {
    guard let navigationController else { return }
    guard isChildAttached else { return }

    childRouter.detachGrandchildIfNeeded(animated: animated)
    deactivateDetachAndPop(
      childRouter,
      in: navigationController,
      to: viewController,
      animated: animated
    )
    isChildAttached = false
    _ = store.send(.childPresentationChanged(false))
  }
}
