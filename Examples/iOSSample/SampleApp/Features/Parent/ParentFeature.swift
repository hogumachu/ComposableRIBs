import ComposableArchitecture
import ComposableRIBs

@Reducer
struct ParentFeature {
  @ObservableState
  struct State: Equatable {
    var counter: Int
  }

  @CasePathable
  enum Action: Equatable {
    case childButtonTapped
    case delegate(Delegate)

    enum Delegate: Equatable {
      case showChildRequested
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .childButtonTapped:
        return .send(.delegate(.showChildRequested))
      case .delegate:
        return .none
      }
    }
  }
}
