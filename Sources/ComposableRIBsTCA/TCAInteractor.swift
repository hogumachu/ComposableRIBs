import ComposableArchitecture
import ComposableRIBsCore
import Foundation

@MainActor
/// Bridges RIB lifecycle ownership into TCA store hosting and owns task cancellation at deactivation.
///
/// Stability: evolving-v0x
public final class TCAInteractor<Feature>: Interactable where Feature: Reducer {
  public let store: StoreOf<Feature>
  private let actionRelay: ActionRelay<Feature.Action>?

  /// Tracks long-running tasks started while active so they can be cancelled deterministically.
  private var managedTasks: [UUID: Task<Void, Never>] = [:]

  public init(store: StoreOf<Feature>, actionRelay: ActionRelay<Feature.Action>? = nil) {
    self.store = store
    self.actionRelay = actionRelay
  }

  /// Convenience initializer that builds a store with action observation wiring.
  ///
  /// Preferred for builder composition to avoid repeating `ActionRelay` and
  /// `ActionObservingReducer` setup in each module builder.
  public convenience init(
    initialState: @autoclosure () -> Feature.State,
    @ReducerBuilder<Feature.State, Feature.Action> reducer: () -> Feature
  ) {
    let actionRelay = ActionRelay<Feature.Action>()
    let store = Store(initialState: initialState()) {
      ActionObservingReducer(base: reducer()) { action in
        actionRelay.emit(action)
      }
    }
    self.init(store: store, actionRelay: actionRelay)
  }

  public func activate() {
    // Lifecycle ownership stays in the interactor/router layer so feature actions can stay pure TCA.
  }

  public func deactivate() {
    // Align with RIB lifecycle semantics: stop all interactor-owned runtime work.
    cancelManagedTasks()
  }

  @discardableResult
  /// Registers a task to be cancelled automatically when the interactor deactivates.
  public func manage(_ task: Task<Void, Never>) -> Task<Void, Never> {
    pruneCancelledTasks()
    managedTasks[UUID()] = task
    return task
  }

  /// Cancels and clears all currently managed tasks.
  public func cancelManagedTasks() {
    for task in managedTasks.values {
      task.cancel()
    }
    managedTasks.removeAll(keepingCapacity: false)
  }

  /// Keeps bookkeeping small by removing tasks that were already cancelled elsewhere.
  private func pruneCancelledTasks() {
    managedTasks = managedTasks.filter { !$0.value.isCancelled }
  }

  /// Registers an action observer when this interactor has an attached action relay.
  ///
  /// Returns `nil` when action observation was not configured for this interactor.
  @discardableResult
  public func observeActions(_ observer: @escaping (Feature.Action) -> Void) -> UUID? {
    actionRelay?.observe(observer)
  }

  /// Removes an action observer previously returned by `observeActions`.
  public func removeActionObserver(_ token: UUID) {
    actionRelay?.removeObserver(token)
  }

}

public extension TCAInteractor where Feature.Action: DelegateActionExtractable {
  /// Registers a delegate-event observer for actions that expose optional delegate events.
  ///
  /// This API is kept for v0.x compatibility. Prefer case-path extraction by calling
  /// `observeDelegateEvents(for:_:)` when action enums have a `case delegate(...)`.
  @discardableResult
  func observeDelegateEvents(
    _ observer: @escaping (Feature.Action.Delegate) -> Void
  ) -> UUID? {
    observeActions { action in
      guard let event = action.delegateEvent else { return }
      observer(event)
    }
  }
}

public extension TCAInteractor where Feature.Action: CasePathable {
  /// Registers a delegate-event observer using a delegate case path.
  ///
  /// This is the preferred delegate extraction path because it avoids per-action
  /// boilerplate like `var delegateEvent`.
  @discardableResult
  func observeDelegateEvents<Delegate>(
    for delegateCase: CaseKeyPath<Feature.Action, Delegate>,
    _ observer: @escaping (Delegate) -> Void
  ) -> UUID? {
    observeActions { action in
      guard let event = action[case: delegateCase] else { return }
      observer(event)
    }
  }
}

public extension TCAInteractor where Feature.Action: Sendable {
  /// Returns an action stream when this interactor has an attached action relay.
  ///
  /// The stream is empty when observation was not configured.
  func actionStream() -> AsyncStream<Feature.Action> {
    guard let actionRelay else {
      return AsyncStream { continuation in
        continuation.finish()
      }
    }
    return actionRelay.makeStream()
  }
}
