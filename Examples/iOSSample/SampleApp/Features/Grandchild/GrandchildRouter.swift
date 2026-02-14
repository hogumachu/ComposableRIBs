import ComposableArchitecture
import ComposableRIBs
import Combine

@MainActor
final class GrandchildRouter: SwiftUIHostingRouter<GrandchildFeature, GrandchildView>, GrandchildRouting {
  private var onCloseRequested: (() -> Void)?

  init(store: StoreOf<GrandchildFeature>, interactor: TCAInteractor<GrandchildFeature>) {
    super.init(store: store, interactor: interactor) {
      GrandchildView(store: store)
    }
  }

  func bind(onCloseRequested: @escaping () -> Void) {
    self.onCloseRequested = onCloseRequested
  }

  override func bindState() {
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
