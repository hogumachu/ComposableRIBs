import ComposableArchitecture
import ComposableRIBsCore
import ComposableRIBsTCA
import Combine
import Foundation
import SwiftUI
import UIKit

/// Routing contract for modules backed by a view controller and lifecycle interactor.
///
/// Stability: evolving-v0x
@MainActor
public protocol RoutableViewControlling: Routing {
  var viewController: UIViewController { get }
  var interactor: any Interactable { get }
}

/// Base router that centralizes SwiftUI hosting and store/interactor wiring boilerplate.
///
/// Stability: evolving-v0x
@MainActor
open class SwiftUIHostingRouter<Feature, RootView>: BaseRouter, RoutableViewControlling
where Feature: Reducer, Feature.State: Equatable, RootView: View {
  private let tcaInteractor: TCAInteractor<Feature>
  public let interactor: any Interactable
  public let viewController: UIViewController
  private var childCleanupByIdentifier: [ObjectIdentifier: () -> Void] = [:]

  /// Shared cancellation set for state binding subscriptions.
  open var cancellables: Set<AnyCancellable> = []

  /// Initializes a hosting router from an interactor and derives the feature store from it.
  ///
  /// This keeps router wiring consistent and avoids duplicated `store` plumbing in builders.
  public init(
    interactor: TCAInteractor<Feature>,
    @ViewBuilder rootView: (StoreOf<Feature>) -> RootView
  ) {
    let store = interactor.store
    self.tcaInteractor = interactor
    self.interactor = interactor
    self.viewController = NavigationLifecycleHostingController(rootView: rootView(store))
    super.init()
    bindState()
  }

  /// Override to subscribe to state changes and trigger router side effects.
  open func bindState() {}

  /// Performs a standard child attach + activate transition without imposing a specific UIKit container.
  public func attachActivate(
    _ child: any RoutableViewControlling,
    onRelease: (() -> Void)? = nil
  ) {
    registerChildLifecycleCleanupIfNeeded(child, onRelease: onRelease)
    attachChild(child)
    child.interactor.activate()
  }

  /// Performs a standard child attach + activate + push transition.
  public func attachActivateAndPush(
    _ child: any RoutableViewControlling,
    in navigationController: UINavigationController,
    animated: Bool,
    onRelease: (() -> Void)? = nil
  ) {
    attachActivate(child, onRelease: onRelease)
    guard !navigationController.viewControllers.contains(child.viewController) else { return }
    navigationController.pushViewController(child.viewController, animated: animated)
  }

  /// Performs a standard child deactivate + detach + pop transition.
  public func deactivateDetachAndPop(
    _ child: any RoutableViewControlling,
    in navigationController: UINavigationController,
    to fallbackViewController: UIViewController,
    animated: Bool,
    onRelease: (() -> Void)? = nil
  ) {
    deactivateDetachAndReleaseIfNeeded(child, onRelease: onRelease)
    guard navigationController.viewControllers.contains(child.viewController) else { return }
    navigationController.popToViewController(fallbackViewController, animated: animated)
  }

  /// Performs a standard child attach + activate + modal present transition.
  public func attachActivateAndPresent(
    _ child: any RoutableViewControlling,
    from presentingViewController: UIViewController,
    animated: Bool,
    onRelease: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
    attachActivate(child, onRelease: onRelease)
    guard child.viewController.presentingViewController == nil else {
      completion?()
      return
    }
    presentingViewController.present(child.viewController, animated: animated, completion: completion)
  }

  /// Performs a standard child deactivate + detach + modal dismiss transition.
  public func deactivateDetachAndDismiss(
    _ child: any RoutableViewControlling,
    animated: Bool,
    onRelease: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
    let isPresented = child.viewController.presentingViewController != nil
    deactivateDetachAndReleaseIfNeeded(child, onRelease: onRelease)
    guard isPresented else {
      completion?()
      return
    }
    child.viewController.dismiss(animated: animated, completion: completion)
  }

  /// Idempotently deactivates, detaches, and releases a child router.
  public func deactivateDetachAndReleaseIfNeeded(
    _ child: any RoutableViewControlling,
    onRelease: (() -> Void)? = nil
  ) {
    let identifier = ObjectIdentifier(child)
    if let cleanup = childCleanupByIdentifier.removeValue(forKey: identifier) {
      cleanup()
      onRelease?()
      return
    }

    guard children.contains(where: { ObjectIdentifier($0) == identifier }) else { return }
    child.interactor.deactivate()
    detachChild(child)
    onRelease?()
  }

  /// Observes feature actions through a case path without exposing feature store or interactor internals.
  @discardableResult
  public func observeAction<ActionValue>(
    for actionCase: CaseKeyPath<Feature.Action, ActionValue>,
    _ observer: @escaping (ActionValue) -> Void
  ) -> UUID? where Feature.Action: CasePathable {
    tcaInteractor.observeDelegateEvents(for: actionCase, observer)
  }

  /// Removes an observer registered via `observeAction(for:_:)`.
  public func removeActionObserver(_ token: UUID) {
    tcaInteractor.removeActionObserver(token)
  }

  private func registerChildLifecycleCleanupIfNeeded(
    _ child: any RoutableViewControlling,
    onRelease: (() -> Void)?
  ) {
    let identifier = ObjectIdentifier(child)
    let emitter = child.viewController as? (any NavigationLifecycleEventEmitting)
    childCleanupByIdentifier[identifier] = { [weak self] in
      guard let self else { return }
      if self.children.contains(where: { ObjectIdentifier($0) == identifier }) {
        child.interactor.deactivate()
        self.detachChild(child)
      }
      emitter?.onNavigationLifecycleEvent = nil
      onRelease?()
    }

    guard let emitter else { return }
    emitter.onNavigationLifecycleEvent = { [weak self] _ in
      guard let self else { return }
      guard let attachedChild = self.children.first(where: { ObjectIdentifier($0) == identifier }) as? (any RoutableViewControlling) else {
        return
      }
      self.deactivateDetachAndReleaseIfNeeded(attachedChild)
    }
  }
}
