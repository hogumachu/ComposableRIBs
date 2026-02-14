import ComposableArchitecture
import ComposableRIBs

@Reducer
struct GrandchildFeature {
  @ObservableState
  struct State: Equatable {
    var isActive = false
    var title: String
  }

  enum Action: Equatable, LifecycleActionConvertible {
    case lifecycle(InteractorLifecycleAction)

    static func makeLifecycleAction(_ action: InteractorLifecycleAction) -> Self {
      .lifecycle(action)
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
      }
    }
  }
}
