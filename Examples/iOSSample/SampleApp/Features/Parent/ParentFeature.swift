import ComposableArchitecture
import ComposableRIBs

@Reducer
struct ParentFeature {
  @ObservableState
  struct State: Equatable {
    var isActive = false
    var isChildPresented = false
    var counter: Int
  }

  @CasePathable
  enum Action: Equatable, LifecycleCaseActionConvertible {
    case lifecycle(InteractorLifecycleAction)
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
      case .lifecycle(.didBecomeActive):
        state.isActive = true
        return .none
      case .lifecycle(.willResignActive):
        state.isActive = false
        return .none
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
