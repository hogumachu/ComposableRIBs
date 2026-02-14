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
      var tickCount = 0
    }

    enum Action: Equatable {
      case tick
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .tick:
          state.tickCount += 1
          return .none
        }
      }
    }
  }

  @Reducer
  struct PureFeature {
    @ObservableState
    struct State: Equatable {
      var value = 0
    }

    enum Action: Equatable {
      case increment
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .increment:
          state.value += 1
          return .none
        }
      }
    }
  }

  @Test("Interactor can be used with pure TCA action without lifecycle case")
  func pureFeatureCanUseInteractor() {
    let store = Store(initialState: PureFeature.State()) { PureFeature() }
    let viewStore = ViewStore(store, observe: { $0 })
    let interactor = TCAInteractor<PureFeature>(store: store)

    interactor.activate()
    viewStore.send(.increment)
    interactor.deactivate()

    #expect(viewStore.value == 1)
  }

  @Test("Interactor activate and deactivate keep reducer state unchanged by default")
  func activateDeactivateDoesNotMutateState() {
    let store = Store(initialState: Feature.State()) { Feature() }
    let viewStore = ViewStore(store, observe: { $0 })
    let interactor = TCAInteractor<Feature>(store: store)

    interactor.activate()
    interactor.activate()
    interactor.deactivate()
    interactor.deactivate()

    #expect(viewStore.tickCount == 0)
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
