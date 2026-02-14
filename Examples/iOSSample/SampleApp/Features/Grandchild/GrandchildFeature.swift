import ComposableArchitecture
import ComposableRIBs

@Reducer
struct GrandchildFeature {
  @ObservableState
  struct State: Equatable {
    var closeRequested = false
    var title: String
  }

  @CasePathable
  enum Action: Equatable {
    case closeTapped
    case closeRequestChanged(Bool)
    case delegate(Delegate)

    enum Delegate: Equatable {
      case closeRequested
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .closeTapped:
        state.closeRequested = true
        return .send(.delegate(.closeRequested))
      case let .closeRequestChanged(value):
        state.closeRequested = value
        return .none
      case .delegate:
        return .none
      }
    }
  }
}
