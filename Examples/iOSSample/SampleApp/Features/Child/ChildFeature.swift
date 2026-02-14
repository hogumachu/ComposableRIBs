import ComposableArchitecture
import ComposableRIBs

@Reducer
struct ChildFeature {
  @ObservableState
  struct State: Equatable {
    var isActive = false
    var showGrandchild = false
    var shouldClose = false
    var ticks = 0
    var seedValue: Int
  }

  enum Action: Equatable, LifecycleCaseActionConvertible {
    case lifecycle(InteractorLifecycleAction)
    case grandchildButtonTapped
    case setGrandchildPresented(Bool)
    case closeTapped
    case closeHandled
    case tick
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
        state.showGrandchild = false
        return .cancel(id: CancelID.ticker)

      case .grandchildButtonTapped:
        state.showGrandchild.toggle()
        return .none

      case let .setGrandchildPresented(isPresented):
        state.showGrandchild = isPresented
        return .none

      case .closeTapped:
        state.shouldClose = true
        return .none

      case .closeHandled:
        state.shouldClose = false
        return .none

      case .tick:
        state.ticks += 1
        return .none
      }
    }
  }
}
