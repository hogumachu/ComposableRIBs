import ComposableArchitecture
import ComposableRIBs
import UIKit

@MainActor
final class ParentRouter: SwiftUIHostingRouter<ParentFeature, ParentView>, ParentRouting {
  private let dependency: any ParentDependency
  private let childBuilder: any ChildBuildable
  private var childRouter: (any ChildRouting)?
  private weak var navigationController: UINavigationController?
  private var isChildAttached = false

  init(
    interactor: TCAInteractor<ParentFeature>,
    dependency: any ParentDependency,
    childBuilder: any ChildBuildable
  ) {
    self.dependency = dependency
    self.childBuilder = childBuilder
    super.init(interactor: interactor) {
      ParentView(store: $0)
    }
  }

  func bind(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }

  override func bindState() {
    // Upstream navigation intent is delegate-first. Router maps delegate actions to UIKit transitions.
    observeAction(for: \.delegate) { [weak self] delegateEvent in
      guard let self else { return }
      switch delegateEvent {
      case .showChildRequested:
        self.presentChildIfNeeded(animated: true)
      }
    }
  }

  private func presentChildIfNeeded(animated: Bool) {
    guard let navigationController else { return }
    guard !isChildAttached else { return }
    guard childRouter == nil else { return }
    let childDependency = ParentComponent(dependency: dependency)
    let childRouter = childBuilder.build(with: childDependency)
    childRouter.bind(navigationController: navigationController, onCloseRequested: { [weak self] in
      self?.dismissChildIfNeeded(animated: true)
    })
    self.childRouter = childRouter
    attachActivateAndPush(childRouter, in: navigationController, animated: animated)
    isChildAttached = true
  }

  private func dismissChildIfNeeded(animated: Bool) {
    guard let navigationController else { return }
    guard let childRouter else { return }
    guard isChildAttached else { return }

    childRouter.detachGrandchildIfNeeded(animated: animated)
    deactivateDetachAndPop(
      childRouter,
      in: navigationController,
      to: viewController,
      animated: animated
    )
    isChildAttached = false
    self.childRouter = nil
  }
}
