import ComposableArchitecture
import ComposableRIBs
import Foundation
import Testing

@MainActor
@Suite("Delegate Action Bridge")
struct DelegateActionBridgeTests {
  @Reducer
  struct DelegateFeature {
    @ObservableState
    struct State: Equatable {
      var count = 0
    }

    enum Action: Equatable, LifecycleCaseActionConvertible, DelegateActionExtractable {
      case lifecycle(InteractorLifecycleAction)
      case incrementTapped
      case delegate(Delegate)

      enum Delegate: Equatable {
        case incrementTapped
      }

      var delegateEvent: Delegate? {
        guard case let .delegate(event) = self else { return nil }
        return event
      }
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .incrementTapped:
          state.count += 1
          return .send(.delegate(.incrementTapped))
        case .delegate, .lifecycle:
          return .none
        }
      }
    }
  }

  @Reducer
  struct PlainFeature {
    @ObservableState
    struct State: Equatable {}

    enum Action: Equatable, LifecycleCaseActionConvertible {
      case lifecycle(InteractorLifecycleAction)
      case noop
    }

    var body: some ReducerOf<Self> {
      Reduce { _, _ in .none }
    }
  }

  @Test("ActionObservingReducer observes direct and internally sent actions")
  func actionObservingReducerObservesAllActions() {
    let relay = ActionRelay<DelegateFeature.Action>()
    let store = Store(initialState: DelegateFeature.State()) {
      ActionObservingReducer(base: DelegateFeature()) { action in
        relay.emit(action)
      }
    }
    let interactor = TCAInteractor<DelegateFeature>(store: store, actionRelay: relay)

    var observed: [DelegateFeature.Action.Delegate] = []
    let token = interactor.observeDelegateEvents { observed.append($0) }

    _ = store.send(.incrementTapped)

    if let token {
      interactor.removeActionObserver(token)
    }

    #expect(observed == [.incrementTapped])
  }

  @Test("TCAInteractor optional delegate observation can be absent")
  func interactorWithoutRelayIsSafe() {
    let store = Store(initialState: PlainFeature.State()) {
      PlainFeature()
    }
    let interactor = TCAInteractor<PlainFeature>(store: store)

    let token = interactor.observeActions { _ in Issue.record("Should not observe without relay") }

    _ = store.send(.noop)

    #expect(token == nil)
  }
}
