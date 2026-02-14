import ComposableArchitecture
import ComposableRIBs

@Reducer
struct GrandchildFeature {
  @ObservableState
  struct State: Equatable {
    var isActive = false
    var closeRequested = false
    var title: String
  }

  enum Action: Equatable, LifecycleCaseActionConvertible, DelegateActionExtractable {
    case lifecycle(InteractorLifecycleAction)
    case closeTapped
    case closeRequestChanged(Bool)
    case delegate(Delegate)

    enum Delegate: Equatable {
      case closeRequested
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
