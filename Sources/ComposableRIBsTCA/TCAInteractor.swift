import ComposableArchitecture
import ComposableRIBsCore
import Foundation

@MainActor
/// Bridges RIB lifecycle hooks into TCA actions and owns task cancellation at deactivation.
open class TCAInteractor<Feature>: Interactable where Feature: Reducer, Feature.Action: LifecycleActionConvertible {
  public let store: StoreOf<Feature>

  /// Tracks long-running tasks started while active so they can be cancelled deterministically.
  private var managedTasks: [UUID: Task<Void, Never>] = [:]

  public init(store: StoreOf<Feature>) {
    self.store = store
  }

  open func activate() {
    _ = store.send(.makeLifecycleAction(.didBecomeActive))
  }

  open func deactivate() {
    _ = store.send(.makeLifecycleAction(.willResignActive))
    // Align with RIB lifecycle semantics: stop all interactor-owned runtime work.
    cancelManagedTasks()
  }

  @discardableResult
  /// Registers a task to be cancelled automatically when the interactor deactivates.
  open func manage(_ task: Task<Void, Never>) -> Task<Void, Never> {
    pruneCancelledTasks()
    managedTasks[UUID()] = task
    return task
  }

  /// Cancels and clears all currently managed tasks.
  open func cancelManagedTasks() {
    for task in managedTasks.values {
      task.cancel()
    }
    managedTasks.removeAll(keepingCapacity: false)
  }

  /// Keeps bookkeeping small by removing tasks that were already cancelled elsewhere.
  private func pruneCancelledTasks() {
    managedTasks = managedTasks.filter { !$0.value.isCancelled }
  }
}
