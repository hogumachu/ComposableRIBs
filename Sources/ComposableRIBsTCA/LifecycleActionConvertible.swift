/// Converts lifecycle events into the reducer's concrete action type.
public protocol LifecycleActionConvertible {
  /// Maps a shared lifecycle event into the module-specific action enum.
  static func makeLifecycleAction(_ action: InteractorLifecycleAction) -> Self
}
