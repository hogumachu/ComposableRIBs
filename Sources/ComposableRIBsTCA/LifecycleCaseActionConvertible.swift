/// Reduces lifecycle forwarding boilerplate for feature actions that include
/// a `case lifecycle(InteractorLifecycleAction)` enum case.
///
/// Stability: evolving-v0x
public protocol LifecycleCaseActionConvertible: LifecycleActionConvertible {
  /// Module-specific lifecycle action case constructor.
  static func lifecycle(_ action: InteractorLifecycleAction) -> Self
}

public extension LifecycleCaseActionConvertible {
  static func makeLifecycleAction(_ action: InteractorLifecycleAction) -> Self {
    lifecycle(action)
  }
}
