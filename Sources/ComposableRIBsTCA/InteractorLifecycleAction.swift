/// Lifecycle events emitted by an interactor and consumed by reducer actions.
public enum InteractorLifecycleAction: Sendable, Equatable {
  case didBecomeActive
  case willResignActive
}
