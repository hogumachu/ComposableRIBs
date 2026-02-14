/// Lifecycle events emitted by an interactor and consumed by reducer actions.
///
/// Stability: evolving-v0x
public enum InteractorLifecycleAction: Sendable, Equatable {
  case didBecomeActive
  case willResignActive
}
