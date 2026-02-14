import ComposableArchitecture
import ComposableRIBs
import Foundation
import Testing

@MainActor
@Suite("TCA Interactor")
struct TCAInteractorTests {
  @Reducer
  struct Feature {
    @ObservableState
    struct State: Equatable {
      var activations = 0
      var deactivations = 0
      var tickCount = 0
    }

    enum Action: Equatable, LifecycleActionConvertible {
      case lifecycle(InteractorLifecycleAction)
      case tick

      static func makeLifecycleAction(_ action: InteractorLifecycleAction) -> Self {
        .lifecycle(action)
      }
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .lifecycle(.didBecomeActive):
          state.activations += 1
          return .none
        case .lifecycle(.willResignActive):
          state.deactivations += 1
          return .none
        case .tick:
          state.tickCount += 1
          return .none
        }
      }
    }
  }

  @Test("Interactor forwards activate/deactivate as lifecycle actions")
  func lifecycleForwarding() {
    let store = Store(initialState: Feature.State()) { Feature() }
    let viewStore = ViewStore(store, observe: { $0 })
    let interactor = TCAInteractor<Feature>(store: store)

    interactor.activate()
    interactor.deactivate()

    #expect(viewStore.activations == 1)
    #expect(viewStore.deactivations == 1)
  }

  @Test("Interactor cancels managed tasks on deactivate")
  func deactivateCancelsManagedTasks() async {
    let store = Store(initialState: Feature.State()) { Feature() }
    let interactor = TCAInteractor<Feature>(store: store)
    let probe = CancellationProbe()

    interactor.activate()
    interactor.manage(
      Task {
        await withTaskCancellationHandler {
          while !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(10))
          }
        } onCancel: {
          Task { await probe.markCancelled() }
        }
      }
    )

    interactor.deactivate()

    for _ in 0..<50 where !(await probe.cancelled) {
      try? await Task.sleep(for: .milliseconds(10))
    }

    #expect(await probe.cancelled)
  }
}

actor CancellationProbe {
  private(set) var cancelled = false

  func markCancelled() {
    cancelled = true
  }
}
