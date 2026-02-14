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
    self.viewController = UIHostingController(rootView: rootView(store))
    super.init()
    bindState()
  }

  /// Override to subscribe to state changes and trigger router side effects.
  open func bindState() {}

  /// Performs a standard child attach + activate + push transition.
  public func attachActivateAndPush(
    _ child: any RoutableViewControlling,
    in navigationController: UINavigationController,
    animated: Bool
  ) {
    attachChild(child)
    child.interactor.activate()
    guard !navigationController.viewControllers.contains(child.viewController) else { return }
    navigationController.pushViewController(child.viewController, animated: animated)
  }

  /// Performs a standard child deactivate + detach + pop transition.
  public func deactivateDetachAndPop(
    _ child: any RoutableViewControlling,
    in navigationController: UINavigationController,
    to fallbackViewController: UIViewController,
    animated: Bool
  ) {
    child.interactor.deactivate()
    detachChild(child)
    guard navigationController.viewControllers.contains(child.viewController) else { return }
    navigationController.popToViewController(fallbackViewController, animated: animated)
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
}
