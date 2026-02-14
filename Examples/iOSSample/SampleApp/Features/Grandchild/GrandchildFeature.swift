import ComposableArchitecture
import ComposableRIBs

@Reducer
struct GrandchildFeature {
  @ObservableState
  struct State: Equatable {
    var title: String
  }

  @CasePathable
  enum Action: Equatable {
    case closeTapped
    case delegate(Delegate)

    enum Delegate: Equatable {
      case closeRequested
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .closeTapped:
        return .send(.delegate(.closeRequested))
      case .delegate:
        return .none
      }
    }
  }
}
