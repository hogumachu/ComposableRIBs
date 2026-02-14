# Module Wiring Guide

## Purpose
This guide explains how to wire ComposableRIBs modules with clear ownership boundaries so modules stay protocol-first, composable, and safe to evolve.

## Wiring Pipeline (Builder-First)
Use this baseline flow for module construction:

`Dependency contract -> Builder -> Interactor -> Router -> ViewController`

Recommended builder path:

1. Accept only dependency contracts (protocols).
2. Build child dependencies through components, not concrete parent types.
3. Create an interactor with the convenience initializer:
   - `TCAInteractor(initialState:) { Feature() }`
4. Create a router that hosts the feature view.
5. Bind navigation ownership in the router only.

Dismissible child lifetime policy:

- Build child modules on demand.
- Attach and present from router methods.
- On close: deactivate, detach, pop/dismiss, and release child reference (`nil`).

## Boundary Rules
1. Parent-child composition must use contracts such as `any ChildBuildable` and `any ChildRouting`.
2. Concrete type leakage across module boundaries is forbidden.
3. SwiftUI views must receive only `StoreOf<Feature>` (or scoped stores), never router references.
4. Reducers own state and business logic.
5. Routers own UIKit navigation side effects.
6. Router code must not dispatch feature actions directly with `store.send`.

## Minimal Parent -> Child Example
```swift
import ComposableArchitecture
import ComposableRIBs

protocol ParentDependency: RIBDependency {
  var initialCounter: Int { get }
}

protocol ParentBuildable: Buildable where Dependency == any ParentDependency, Routing == any ParentRouting {}

protocol ParentRouting: Routing {
  var interactor: TCAInteractor<ParentFeature> { get }
  func bind(navigationController: UINavigationController)
}

protocol ChildBuildable {
  func build(with dependency: any ChildDependency) -> any ChildRouting
}

@MainActor
final class ParentBuilder: ParentBuildable {
  private let childBuilder: any ChildBuildable

  init(childBuilder: any ChildBuildable = ChildBuilder()) {
    self.childBuilder = childBuilder
  }

  func build(with dependency: any ParentDependency) -> any ParentRouting {
    let interactor = TCAInteractor(initialState: ParentFeature.State(counter: dependency.initialCounter)) {
      ParentFeature()
    }
    return ParentRouter(interactor: interactor, childBuilder: childBuilder)
  }
}

@MainActor
final class ParentRouter: SwiftUIHostingRouter<ParentFeature, ParentView>, ParentRouting {
  private let childBuilder: any ChildBuildable
  private weak var navigationController: UINavigationController?
  private var childRouter: (any ChildRouting)?

  init(interactor: TCAInteractor<ParentFeature>, childBuilder: any ChildBuildable) {
    self.childBuilder = childBuilder
    super.init(interactor: interactor) { store in
      ParentView(store: store)
    }
  }

  func bind(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }

  override func bindState() {
    // Observe delegate actions and route in UIKit layer.
    observeAction(for: \.delegate) { [weak self] delegate in
      guard let self else { return }
      if case .showChildRequested = delegate {
        self.presentChildIfNeeded()
      }
    }
  }

  private func presentChildIfNeeded() {
    guard childRouter == nil, let navigationController else { return }
    let dependency = ParentToChildComponent(dependency: interactor.store)
    let child = childBuilder.build(with: dependency)
    child.bind(navigationController: navigationController)
    attachChild(child)
    child.interactor.activate()
    navigationController.pushViewController(child.viewController, animated: true)
    childRouter = child
  }

  private func dismissChildIfNeeded() {
    guard let childRouter else { return }
    childRouter.interactor.deactivate()
    detachChild(childRouter)
    navigationController?.popToViewController(viewController, animated: true)
    self.childRouter = nil
  }
}
```

## Common Pitfalls
1. Long-lived strong child router references for dismissible flows cause `deinit` leaks.
2. State-flag polling for routing (`showX`, `shouldClose`) creates implicit coupling and stale transitions.
3. Passing concrete parent dependencies into child builders breaks protocol-first boundaries.
4. Routing logic in reducers or views blurs ownership and makes lifecycle behavior harder to test.

## Review Checklist
1. Builder inputs and outputs are contract-based (`any Protocol`), not concrete module types.
2. Router is the only layer performing UIKit push/pop/present/dismiss.
3. Views do not import or store router references.
4. Router does not send feature actions directly.
5. Dismissible child routers are built on demand and released on close.
6. Duplicate attach is guarded and non-existent detach is no-op safe.
7. Architecture changes update docs (`README.md`, guide docs, roadmap/status) in the same milestone.
