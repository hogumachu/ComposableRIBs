import ComposableArchitecture
import ComposableRIBs
import Combine
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
      _ = self?.store.send(.setChildPresented(false))
    })
    syncChildPresentation(shouldShow: viewStore.showChild, animated: false)
  }

  override func bindState() {
    // Navigation is state-driven: reducer toggles state, router performs UIKit side effects.
    viewStore.publisher.showChild
      .removeDuplicates()
      .sink { [weak self] shouldShow in
        self?.syncChildPresentation(shouldShow: shouldShow, animated: true)
      }
      .store(in: &cancellables)
  }

  private func syncChildPresentation(shouldShow: Bool, animated: Bool) {
    guard let navigationController else { return }

    if shouldShow {
      guard !isChildAttached else { return }
      attachActivateAndPush(childRouter, in: navigationController, animated: animated)
      isChildAttached = true
      return
    }

    guard isChildAttached else { return }

    childRouter.detachGrandchildIfNeeded(animated: animated)
    deactivateDetachAndPop(
      childRouter,
      in: navigationController,
      to: viewController,
      animated: animated
    )
    isChildAttached = false
  }
}
