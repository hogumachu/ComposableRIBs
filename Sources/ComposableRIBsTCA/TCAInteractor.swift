import ComposableArchitecture
import ComposableRIBsCore
import Foundation

@MainActor
/// Bridges RIB lifecycle hooks into TCA actions and owns task cancellation at deactivation.
///
/// Stability: evolving-v0x
public final class TCAInteractor<Feature>: Interactable where Feature: Reducer, Feature.Action: LifecycleActionConvertible {
  public let store: StoreOf<Feature>
  private let actionRelay: ActionRelay<Feature.Action>?

  /// Tracks long-running tasks started while active so they can be cancelled deterministically.
  private var managedTasks: [UUID: Task<Void, Never>] = [:]

  public init(store: StoreOf<Feature>, actionRelay: ActionRelay<Feature.Action>? = nil) {
    self.store = store
    self.actionRelay = actionRelay
  }

  public func activate() {
    _ = store.send(.makeLifecycleAction(.didBecomeActive))
  }

  public func deactivate() {
    _ = store.send(.makeLifecycleAction(.willResignActive))
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
