import ComposableArchitecture
import ComposableRIBs

@Reducer
struct ParentFeature {
  @ObservableState
  struct State: Equatable {
    var isChildPresented = false
    var counter: Int
  }

  @CasePathable
  enum Action: Equatable {
    case childButtonTapped
    case childPresentationChanged(Bool)
    case delegate(Delegate)

    enum Delegate: Equatable {
      case showChildRequested
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .childButtonTapped:
        return .send(.delegate(.showChildRequested))
      case let .childPresentationChanged(isPresented):
        state.isChildPresented = isPresented
        return .none
      case .delegate:
        return .none
      }
    }
  }
}
