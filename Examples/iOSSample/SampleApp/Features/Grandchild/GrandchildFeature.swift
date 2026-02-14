import ComposableArchitecture
import ComposableRIBs

@Reducer
struct GrandchildFeature {
  @ObservableState
  struct State: Equatable {
    var isActive = false
    var shouldClose = false
    var title: String
  }

  enum Action: Equatable, LifecycleCaseActionConvertible {
    case lifecycle(InteractorLifecycleAction)
    case closeTapped
    case closeHandled
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
        state.shouldClose = true
        return .none
      case .closeHandled:
        state.shouldClose = false
        return .none
      }
    }
  }
}
