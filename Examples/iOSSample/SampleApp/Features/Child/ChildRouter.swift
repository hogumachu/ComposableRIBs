import ComposableArchitecture
import ComposableRIBs
import Combine
import SwiftUI
import UIKit

@MainActor
final class ChildRouter: BaseRouter {
  let store: StoreOf<ChildFeature>
  let interactor: TCAInteractor<ChildFeature>
  let grandchildRouter: GrandchildRouter
  let viewController: UIViewController

  private let viewStore: ViewStoreOf<ChildFeature>
  private var cancellables: Set<AnyCancellable> = []
  private weak var navigationController: UINavigationController?
  private var isGrandchildAttached = false
  private var onCloseRequested: (() -> Void)?

  init(
    store: StoreOf<ChildFeature>,
    interactor: TCAInteractor<ChildFeature>,
    grandchildRouter: GrandchildRouter
  ) {
    self.store = store
    self.interactor = interactor
    self.grandchildRouter = grandchildRouter
    self.viewStore = ViewStore(store, observe: { $0 })
    self.viewController = UIHostingController(rootView: ChildView(store: store))
    super.init()
    bindState()
  }

  func bind(
    navigationController: UINavigationController,
    onCloseRequested: @escaping () -> Void
  ) {
    self.navigationController = navigationController
    self.onCloseRequested = onCloseRequested
    grandchildRouter.bind(onCloseRequested: { [weak self] in
      _ = self?.store.send(.setGrandchildPresented(false))
    })

    syncGrandchildPresentation(shouldShow: viewStore.showGrandchild, animated: false)
  }

  func detachGrandchildIfNeeded(animated: Bool) {
    if viewStore.showGrandchild {
      _ = store.send(.setGrandchildPresented(false))
      return
    }
    syncGrandchildPresentation(shouldShow: false, animated: animated)
  }

  private func bindState() {
    // Router derives UIKit navigation from state to keep View/Reducer free of imperative routing calls.
    viewStore.publisher.showGrandchild
      .removeDuplicates()
      .sink { [weak self] shouldShow in
        self?.syncGrandchildPresentation(shouldShow: shouldShow, animated: true)
      }
      .store(in: &cancellables)

    viewStore.publisher.shouldClose
      .removeDuplicates()
      .filter { $0 }
      .sink { [weak self] _ in
        guard let self else { return }
        self.onCloseRequested?()
        _ = self.store.send(.closeHandled)
      }
      .store(in: &cancellables)
  }

  private func syncGrandchildPresentation(shouldShow: Bool, animated: Bool) {
    guard let navigationController else { return }

    if shouldShow {
      guard !isGrandchildAttached else { return }
      attachChild(grandchildRouter)
      grandchildRouter.interactor.activate()
      navigationController.pushViewController(grandchildRouter.viewController, animated: animated)
      isGrandchildAttached = true
      return
    }

    guard isGrandchildAttached else { return }

    grandchildRouter.interactor.deactivate()
    detachChild(grandchildRouter)
    if navigationController.viewControllers.contains(grandchildRouter.viewController) {
      navigationController.popToViewController(viewController, animated: animated)
    }
    isGrandchildAttached = false
  }
}
