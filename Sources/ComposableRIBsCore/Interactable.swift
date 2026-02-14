@MainActor
/// Defines lifecycle hooks for runtime units that can be activated and deactivated.
///
/// Stability: stable-v0x
public protocol Interactable: AnyObject {
  /// Called when the module becomes active and should start runtime work.
  func activate()
  /// Called before the module resigns active and should stop runtime work.
  func deactivate()
}
