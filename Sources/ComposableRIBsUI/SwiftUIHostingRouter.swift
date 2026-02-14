import ComposableArchitecture
import ComposableRIBsCore
import ComposableRIBsTCA
import Combine
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
where Feature: Reducer, Feature.State: Equatable, Feature.Action: LifecycleActionConvertible, RootView: View {
  public let store: StoreOf<Feature>
  public let interactor: any Interactable
  public let tcaInteractor: TCAInteractor<Feature>
  public let viewStore: ViewStoreOf<Feature>
  public let viewController: UIViewController

  /// Shared cancellation set for state binding subscriptions.
  open var cancellables: Set<AnyCancellable> = []

  public init(
    store: StoreOf<Feature>,
    interactor: TCAInteractor<Feature>,
    @ViewBuilder rootView: () -> RootView
  ) {
    self.store = store
    self.tcaInteractor = interactor
    self.interactor = interactor
    self.viewStore = ViewStore(store, observe: { $0 })
    self.viewController = UIHostingController(rootView: rootView())
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
}
