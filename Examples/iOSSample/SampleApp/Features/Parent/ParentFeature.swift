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

  enum Action: Equatable, LifecycleCaseActionConvertible, DelegateActionExtractable {
    case lifecycle(InteractorLifecycleAction)
    case childButtonTapped
    case childPresentationChanged(Bool)
    case delegate(Delegate)

    enum Delegate: Equatable {
      case showChildRequested
    }

    var delegateEvent: Delegate? {
      guard case let .delegate(event) = self else { return nil }
      return event
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
