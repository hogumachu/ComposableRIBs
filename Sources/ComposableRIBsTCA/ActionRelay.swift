import Foundation

/// Lightweight action broadcaster used to bridge reducer actions to router/interactor observers.
///
/// Stability: evolving-v0x
public final class ActionRelay<Action> {
  private let lock = NSLock()
  private var observers: [UUID: (Action) -> Void] = [:]

  public init() {}

  /// Broadcasts an action to all active observers.
  public func emit(_ action: Action) {
    let currentObservers: [(Action) -> Void]
    lock.lock()
    currentObservers = Array(observers.values)
    lock.unlock()

    for observer in currentObservers {
      observer(action)
    }
  }

  /// Registers an observer and returns a token that can be used to remove it later.
  @discardableResult
  public func observe(_ observer: @escaping (Action) -> Void) -> UUID {
    let token = UUID()
    lock.lock()
    observers[token] = observer
    lock.unlock()
    return token
  }

  /// Removes a previously registered observer token.
  public func removeObserver(_ token: UUID) {
    lock.lock()
    observers.removeValue(forKey: token)
    lock.unlock()
  }

}

public extension ActionRelay where Action: Sendable {
  /// Exposes action events as an async stream for consumers that prefer async iteration.
  func makeStream() -> AsyncStream<Action> {
    AsyncStream { continuation in
      _ = observe { action in
        continuation.yield(action)
      }
    }
  }
}
