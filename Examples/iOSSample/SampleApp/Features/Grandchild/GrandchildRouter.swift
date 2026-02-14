import ComposableArchitecture
import ComposableRIBs

@MainActor
final class GrandchildRouter: SwiftUIHostingRouter<GrandchildFeature, GrandchildView>, GrandchildRouting {
  private var onCloseRequested: (() -> Void)?

  init(interactor: TCAInteractor<GrandchildFeature>) {
    super.init(interactor: interactor) {
      GrandchildView(store: $0)
    }
  }

  func bind(onCloseRequested: @escaping () -> Void) {
    self.onCloseRequested = onCloseRequested
  }

  override func bindState() {
    observeAction(for: \.delegate) { [weak self] delegateEvent in
      guard let self else { return }
      switch delegateEvent {
      case .closeRequested:
        self.onCloseRequested?()
      }
    }
  }
}
