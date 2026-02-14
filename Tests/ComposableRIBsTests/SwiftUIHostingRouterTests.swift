import ComposableArchitecture
import ComposableRIBs
import SwiftUI
import Testing
import UIKit

@MainActor
@Suite("SwiftUI Hosting Router")
struct SwiftUIHostingRouterTests {
  @Reducer
  struct HostFeature {
    @ObservableState
    struct State: Equatable {
      var value = 0
    }

    enum Action: Equatable {
      case noop
    }

    var body: some ReducerOf<Self> {
      Reduce { _, _ in .none }
    }
  }

  final class HostRouter: SwiftUIHostingRouter<HostFeature, EmptyView> {
    init() {
      let store = Store(initialState: HostFeature.State()) { HostFeature() }
      let interactor = TCAInteractor<HostFeature>(store: store)
      super.init(interactor: interactor) { _ in EmptyView() }
    }
  }

  final class ChildRouter: BaseRouter, RoutableViewControlling {
    let viewController = UIViewController()
    let interactor: any Interactable

    init(interactor: any Interactable) {
      self.interactor = interactor
      super.init()
    }
  }

  final class SpyInteractor: Interactable {
    private(set) var activateCount = 0
    private(set) var deactivateCount = 0

    func activate() {
      activateCount += 1
    }

    func deactivate() {
      deactivateCount += 1
    }
  }

  @Test("attachActivateAndPush performs one attach and one push for repeated calls")
  func attachActivateAndPushIsIdempotentForNavigationStack() {
    let host = HostRouter()
    let navigationController = UINavigationController(rootViewController: host.viewController)
    let spy = SpyInteractor()
    let child = ChildRouter(interactor: spy)

    host.attachActivateAndPush(child, in: navigationController, animated: false)
    host.attachActivateAndPush(child, in: navigationController, animated: false)

    #expect(host.children.count == 1)
    #expect(spy.activateCount == 2)
    #expect(navigationController.viewControllers.filter { $0 === child.viewController }.count == 1)
  }

  @Test("deactivateDetachAndPop detaches and deactivates child safely")
  func deactivateDetachAndPopSynchronizesChildLifecycleAndTree() {
    let host = HostRouter()
    let navigationController = UINavigationController(rootViewController: host.viewController)
    let spy = SpyInteractor()
    let child = ChildRouter(interactor: spy)

    host.attachActivateAndPush(child, in: navigationController, animated: false)
    host.deactivateDetachAndPop(
      child,
      in: navigationController,
      to: host.viewController,
      animated: false
    )

    #expect(host.children.isEmpty)
    #expect(spy.deactivateCount == 1)
    #expect(navigationController.topViewController === host.viewController)
  }
}
