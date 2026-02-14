import ComposableArchitecture
import ComposableRIBs

@Reducer
struct ChildFeature {
  @ObservableState
  struct State: Equatable {
    var isActive = false
    var isGrandchildPresented = false
    var ticks = 0
    var seedValue: Int
  }

  enum Action: Equatable, LifecycleCaseActionConvertible, DelegateActionExtractable {
    case lifecycle(InteractorLifecycleAction)
    case grandchildButtonTapped
    case grandchildPresentationChanged(Bool)
    case closeTapped
    case tick
    case delegate(Delegate)

    enum Delegate: Equatable {
      case showGrandchildRequested
      case closeRequested
    }

    var delegateEvent: Delegate? {
      guard case let .delegate(event) = self else { return nil }
      return event
    }
  }

  private enum CancelID: Hashable {
    case ticker
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .lifecycle(.didBecomeActive):
        state.isActive = true
        return .run { send in
          while !Task.isCancelled {
            try await Task.sleep(for: .seconds(1))
            await send(.tick)
          }
        }
        .cancellable(id: CancelID.ticker, cancelInFlight: true)

      case .lifecycle(.willResignActive):
        state.isActive = false
        state.isGrandchildPresented = false
        return .cancel(id: CancelID.ticker)

      case .grandchildButtonTapped:
        return .send(.delegate(.showGrandchildRequested))

      case let .grandchildPresentationChanged(isPresented):
        state.isGrandchildPresented = isPresented
        return .none

      case .closeTapped:
        return .send(.delegate(.closeRequested))

      case .delegate:
        return .none

      case .tick:
        state.ticks += 1
        return .none
      }
    }
  }
}
