import ComposableArchitecture
import ComposableRIBs

@Reducer
struct ParentFeature {
  @ObservableState
  struct State: Equatable {
    var isActive = false
    var showChild = false
    var counter: Int
  }

  enum Action: Equatable, LifecycleActionConvertible {
    case lifecycle(InteractorLifecycleAction)
    case childButtonTapped
    case setChildPresented(Bool)

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
      case .childButtonTapped:
        state.showChild.toggle()
        return .none
      case let .setChildPresented(isPresented):
        state.showChild = isPresented
        return .none
      }
    }
  }
}
