import ComposableArchitecture
import ComposableRIBs
import Combine
import SwiftUI
import UIKit

@MainActor
final class ParentRouter: BaseRouter {
  let store: StoreOf<ParentFeature>
  let interactor: TCAInteractor<ParentFeature>
  let childRouter: ChildRouter
  let viewController: UIViewController

  private let viewStore: ViewStoreOf<ParentFeature>
  private var cancellables: Set<AnyCancellable> = []
  private weak var navigationController: UINavigationController?
  private var isChildAttached = false

  init(store: StoreOf<ParentFeature>, interactor: TCAInteractor<ParentFeature>, childRouter: ChildRouter) {
    self.store = store
    self.interactor = interactor
    self.childRouter = childRouter
    self.viewStore = ViewStore(store, observe: { $0 })
    self.viewController = UIHostingController(rootView: ParentView(store: store))
    super.init()
    bindState()
  }

  func bind(navigationController: UINavigationController) {
    self.navigationController = navigationController
    childRouter.bind(navigationController: navigationController, onCloseRequested: { [weak self] in
      _ = self?.store.send(.setChildPresented(false))
    })

    syncChildPresentation(shouldShow: viewStore.showChild, animated: false)
  }

  private func bindState() {
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
      attachChild(childRouter)
      childRouter.interactor.activate()
      navigationController.pushViewController(childRouter.viewController, animated: animated)
      isChildAttached = true
      return
    }

    guard isChildAttached else { return }

    childRouter.detachGrandchildIfNeeded(animated: animated)
    childRouter.interactor.deactivate()
    detachChild(childRouter)
    if navigationController.viewControllers.contains(childRouter.viewController) {
      navigationController.popToViewController(viewController, animated: animated)
    }
    isChildAttached = false
  }
}
