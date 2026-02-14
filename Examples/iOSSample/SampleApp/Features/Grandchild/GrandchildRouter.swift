import ComposableArchitecture
import ComposableRIBs

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
    _ = tcaInteractor.observeDelegateEvents(for: \.delegate) { [weak self] delegateEvent in
      guard let self else { return }
      switch delegateEvent {
      case .closeRequested:
        self.onCloseRequested?()
        _ = self.store.send(.closeRequestChanged(false))
      }
    }
  }
}
