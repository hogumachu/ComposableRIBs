import ComposableArchitecture
import ComposableRIBs
import Combine
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

  override func bindState() {
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
      attachActivateAndPush(grandchildRouter, in: navigationController, animated: animated)
      isGrandchildAttached = true
      return
    }

    guard isGrandchildAttached else { return }
    deactivateDetachAndPop(
      grandchildRouter,
      in: navigationController,
      to: viewController,
      animated: animated
    )
    isGrandchildAttached = false
  }
}
