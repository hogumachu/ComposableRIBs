@MainActor
/// Defines lifecycle hooks for runtime units that can be activated and deactivated.
public protocol Interactable: AnyObject {
  /// Called when the module becomes active and should start runtime work.
  func activate()
  /// Called before the module resigns active and should stop runtime work.
  func deactivate()
}
