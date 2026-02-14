import UIKit

/// Contract for app launch coordinators that attach a routing root to a window.
///
/// Stability: evolving-v0x
@MainActor
public protocol LaunchRouting: AnyObject {
  /// Launches the application flow by connecting the prepared root module to a window.
  func launch(from window: UIWindow)
}
