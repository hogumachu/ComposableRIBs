import ComposableArchitecture
import ComposableRIBs
import Combine
import SwiftUI
import UIKit

@MainActor
final class GrandchildRouter: BaseRouter {
  let store: StoreOf<GrandchildFeature>
  let interactor: TCAInteractor<GrandchildFeature>
  let viewController: UIViewController

  private let viewStore: ViewStoreOf<GrandchildFeature>
  private var cancellables: Set<AnyCancellable> = []
  private var onCloseRequested: (() -> Void)?

  init(store: StoreOf<GrandchildFeature>, interactor: TCAInteractor<GrandchildFeature>) {
    self.store = store
    self.interactor = interactor
    self.viewStore = ViewStore(store, observe: { $0 })
    self.viewController = UIHostingController(rootView: GrandchildView(store: store))
    super.init()
    bindState()
  }

  func bind(onCloseRequested: @escaping () -> Void) {
    self.onCloseRequested = onCloseRequested
  }

  private func bindState() {
    // Close intent is owned by TCA state; router performs UIKit dismissal side effects.
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
}
