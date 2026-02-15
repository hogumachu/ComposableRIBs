import SwiftUI
import UIKit

/// Navigation lifecycle events emitted when a hosted view controller is removed from UI hierarchy.
///
/// Stability: evolving-v0x
@MainActor
public enum NavigationLifecycleEvent {
  case removedFromParent
  case dismissed
}

@MainActor
protocol NavigationLifecycleEventEmitting: AnyObject {
  var onNavigationLifecycleEvent: ((NavigationLifecycleEvent) -> Void)? { get set }
}

/// Hosting controller that emits one-shot navigation lifecycle events for pop/dismiss paths.
///
/// Stability: evolving-v0x
@MainActor
public final class NavigationLifecycleHostingController<Content: View>: UIHostingController<Content>, NavigationLifecycleEventEmitting {
  var onNavigationLifecycleEvent: ((NavigationLifecycleEvent) -> Void)?
  private var hasEmittedLifecycleEvent = false

  public override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)
    guard parent == nil, !hasEmittedLifecycleEvent else { return }
    emitLifecycleEvent(.removedFromParent)
  }

  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    guard !hasEmittedLifecycleEvent else { return }
    guard isBeingDismissed || navigationController?.isBeingDismissed == true else { return }
    emitLifecycleEvent(.dismissed)
  }

  private func emitLifecycleEvent(_ event: NavigationLifecycleEvent) {
    hasEmittedLifecycleEvent = true
    onNavigationLifecycleEvent?(event)
  }
}
