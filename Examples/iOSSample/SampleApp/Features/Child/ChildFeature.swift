import ComposableArchitecture
import ComposableRIBs

@Reducer
struct ChildFeature {
  @ObservableState
  struct State: Equatable {
    var isGrandchildPresented = false
    var ticks = 0
    var seedValue: Int
  }

  @CasePathable
  enum Action: Equatable {
    case viewAppeared
    case viewDisappeared
    case grandchildButtonTapped
    case grandchildPresentationChanged(Bool)
    case closeTapped
    case tick
    case delegate(Delegate)

    enum Delegate: Equatable {
      case showGrandchildRequested
      case closeRequested
    }
  }

  private enum CancelID: Hashable {
    case ticker
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .viewAppeared:
        // Keep timer ownership in pure TCA reducer logic.
        return .run { send in
          while !Task.isCancelled {
            try await Task.sleep(for: .seconds(1))
            await send(.tick)
          }
        }
        .cancellable(id: CancelID.ticker, cancelInFlight: true)

      case .viewDisappeared:
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
