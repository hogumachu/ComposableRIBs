import ComposableArchitecture

/// Wraps a reducer and forwards every processed action to an observer callback.
///
/// Stability: evolving-v0x
public struct ActionObservingReducer<Base>: Reducer where Base: Reducer {
  private let base: Base
  private let observer: (Base.Action) -> Void

  public init(base: Base, observer: @escaping (Base.Action) -> Void) {
    self.base = base
    self.observer = observer
  }

  public func reduce(into state: inout Base.State, action: Base.Action) -> Effect<Base.Action> {
    observer(action)
    return base.reduce(into: &state, action: action)
  }
}
