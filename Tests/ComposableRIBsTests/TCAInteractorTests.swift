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

  @Test("Interactor forwards each activate call")
  func repeatedActivateForwarding() {
    let store = Store(initialState: Feature.State()) { Feature() }
    let viewStore = ViewStore(store, observe: { $0 })
    let interactor = TCAInteractor<Feature>(store: store)

    interactor.activate()
    interactor.activate()

    #expect(viewStore.activations == 2)
    #expect(viewStore.deactivations == 0)
  }

  @Test("Interactor forwards deactivate without prior activate")
  func deactivateWithoutActivateForwarding() {
    let store = Store(initialState: Feature.State()) { Feature() }
    let viewStore = ViewStore(store, observe: { $0 })
    let interactor = TCAInteractor<Feature>(store: store)

    interactor.deactivate()

    #expect(viewStore.activations == 0)
    #expect(viewStore.deactivations == 1)
  }

  @Test("Interactor forwards lifecycle across activate-deactivate-activate cycle")
  func activateDeactivateActivateCycleForwarding() {
    let store = Store(initialState: Feature.State()) { Feature() }
    let viewStore = ViewStore(store, observe: { $0 })
    let interactor = TCAInteractor<Feature>(store: store)

    interactor.activate()
    interactor.deactivate()
    interactor.activate()

    #expect(viewStore.activations == 2)
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

  @Test("Interactor cancels multiple managed tasks on deactivate")
  func deactivateCancelsMultipleManagedTasks() async {
    let store = Store(initialState: Feature.State()) { Feature() }
    let interactor = TCAInteractor<Feature>(store: store)
    let counter = CancellationCounter()

    interactor.manage(cancellableTask(counter: counter))
    interactor.manage(cancellableTask(counter: counter))
    interactor.manage(cancellableTask(counter: counter))

    interactor.deactivate()

    for _ in 0..<80 where (await counter.value) < 3 {
      try? await Task.sleep(for: .milliseconds(10))
    }

    #expect(await counter.value == 3)
  }

  @Test("cancelManagedTasks can be called before deactivate and remains safe")
  func directCancelBeforeDeactivateIsSafe() async {
    let store = Store(initialState: Feature.State()) { Feature() }
    let interactor = TCAInteractor<Feature>(store: store)
    let counter = CancellationCounter()

    interactor.manage(cancellableTask(counter: counter))
    interactor.manage(cancellableTask(counter: counter))
    interactor.cancelManagedTasks()
    interactor.deactivate()

    for _ in 0..<80 where (await counter.value) < 2 {
      try? await Task.sleep(for: .milliseconds(10))
    }

    #expect(await counter.value == 2)
  }

  @Test("Already cancelled tasks do not prevent later managed task cancellation")
  func alreadyCancelledTasksArePrunedBySubsequentManage() async {
    let store = Store(initialState: Feature.State()) { Feature() }
    let interactor = TCAInteractor<Feature>(store: store)
    let counter = CancellationCounter()

    let preCancelled = Task<Void, Never> {}
    preCancelled.cancel()
    interactor.manage(preCancelled)

    interactor.manage(cancellableTask(counter: counter))
    interactor.deactivate()

    for _ in 0..<80 where (await counter.value) < 1 {
      try? await Task.sleep(for: .milliseconds(10))
    }

    #expect(await counter.value == 1)
  }

  private func cancellableTask(counter: CancellationCounter) -> Task<Void, Never> {
    Task {
      await withTaskCancellationHandler {
        while !Task.isCancelled {
          try? await Task.sleep(for: .milliseconds(10))
        }
      } onCancel: {
        Task { await counter.increment() }
      }
    }
  }
}

actor CancellationProbe {
  private(set) var cancelled = false

  func markCancelled() {
    cancelled = true
  }
}

actor CancellationCounter {
  private var count = 0

  var value: Int { count }

  func increment() {
    count += 1
  }
}
