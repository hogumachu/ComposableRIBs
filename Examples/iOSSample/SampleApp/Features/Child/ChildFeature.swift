import ComposableArchitecture
import ComposableRIBs

@Reducer
struct ChildFeature {
  @ObservableState
  struct State: Equatable {
    var isActive = false
    var showGrandchild = false
    var ticks = 0
    var seedValue: Int
  }

  enum Action: Equatable, LifecycleActionConvertible {
    case lifecycle(InteractorLifecycleAction)
    case toggleGrandchildTapped
    case tick

    static func makeLifecycleAction(_ action: InteractorLifecycleAction) -> Self {
      .lifecycle(action)
    }
  }

  private enum CancelID: Hashable {
    case ticker
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .lifecycle(.didBecomeActive):
        state.isActive = true
        return .run { send in
          while !Task.isCancelled {
            try await Task.sleep(for: .seconds(1))
            await send(.tick)
          }
        }
        .cancellable(id: CancelID.ticker, cancelInFlight: true)

      case .lifecycle(.willResignActive):
        state.isActive = false
        return .cancel(id: CancelID.ticker)

      case .toggleGrandchildTapped:
        state.showGrandchild.toggle()
        return .none

      case .tick:
        state.ticks += 1
        return .none
      }
    }
  }
}
