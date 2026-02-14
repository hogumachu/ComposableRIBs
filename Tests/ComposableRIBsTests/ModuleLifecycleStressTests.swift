import ComposableArchitecture
import ComposableRIBs
import Foundation
import Testing

@MainActor
@Suite("Module Lifecycle Stress")
struct ModuleLifecycleStressTests {
  @Reducer
  struct LifecycleFeature {
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

  final class ParentRouter: BaseRouter {
    let interactor: TCAInteractor<LifecycleFeature>
    let child: ChildRouter

    init(interactor: TCAInteractor<LifecycleFeature>, child: ChildRouter) {
      self.interactor = interactor
      self.child = child
      super.init()
      attachChild(child)
    }
  }

  final class ChildRouter: BaseRouter {
    let interactor: TCAInteractor<LifecycleFeature>
    let grandchild: GrandchildRouter

    init(interactor: TCAInteractor<LifecycleFeature>, grandchild: GrandchildRouter) {
      self.interactor = interactor
      self.grandchild = grandchild
      super.init()
      attachChild(grandchild)
    }
  }

  final class GrandchildRouter: BaseRouter {
    let interactor: TCAInteractor<LifecycleFeature>

    init(interactor: TCAInteractor<LifecycleFeature>) {
      self.interactor = interactor
      super.init()
    }
  }

  @Test("100 activation cycles do not leak managed tasks")
  func noManagedTaskLeakAcrossActivationCycles() async {
    let interactor = makeInteractor()
    let counter = StressCancellationCounter()

    for _ in 0..<100 {
      interactor.activate()
      interactor.manage(cancellableTask(counter: counter))
      interactor.deactivate()
    }

    await waitUntil(timeoutMilliseconds: 2_000) {
      await counter.cancelledCount == 100
    }

    #expect(await counter.cancelledCount == 100)
  }

  @Test("Concurrent route intents preserve router invariants")
  func concurrentAttachIntentsPreserveInvariants() async {
    let tree = makeRouterTree()

    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<50 {
        group.addTask { @MainActor in
          tree.parent.attachChild(tree.child)
          tree.child.attachChild(tree.grandchild)
        }
      }
    }

    #expect(tree.parent.children.count == 1)
    #expect(tree.child.children.count == 1)
    #expect(ObjectIdentifier(tree.parent.children[0]) == ObjectIdentifier(tree.child))
    #expect(ObjectIdentifier(tree.child.children[0]) == ObjectIdentifier(tree.grandchild))
  }

  @Test("Rapid push-pop simulation keeps module tree consistent")
  func rapidAttachDetachRemainsConsistent() {
    let tree = makeRouterTree()

    for _ in 0..<100 {
      tree.parent.attachChild(tree.child)
      tree.child.attachChild(tree.grandchild)
      tree.grandchild.interactor.activate()
      tree.grandchild.interactor.deactivate()
      tree.child.detachChild(tree.grandchild)
      tree.parent.detachChild(tree.child)

      #expect(tree.parent.children.isEmpty)
      #expect(tree.child.children.isEmpty)

      tree.parent.attachChild(tree.child)
      tree.child.attachChild(tree.grandchild)
    }

    #expect(tree.parent.children.count == 1)
    #expect(tree.child.children.count == 1)
    #expect(ObjectIdentifier(tree.parent.children[0]) == ObjectIdentifier(tree.child))
    #expect(ObjectIdentifier(tree.child.children[0]) == ObjectIdentifier(tree.grandchild))
  }

  @Test("Detached child router deinitializes while parent remains alive")
  func detachedChildRouterDeinitializes() {
    let parent = EphemeralParentRouter {
      EphemeralChildRouter {
        EphemeralGrandchildRouter()
      }
    }

    weak var weakChild: EphemeralChildRouter?
    weak var weakGrandchild: EphemeralGrandchildRouter?

    parent.presentChildIfNeeded()
    if let child = parent.childRouter {
      child.presentGrandchildIfNeeded()
      weakChild = child
      weakGrandchild = child.grandchildRouter
    }

    #expect(parent.children.count == 1)
    parent.dismissChildIfNeeded()
    #expect(parent.children.isEmpty)
    #expect(weakChild == nil)
    #expect(weakGrandchild == nil)
  }

  private func makeRouterTree() -> (parent: ParentRouter, child: ChildRouter, grandchild: GrandchildRouter) {
    let grandchild = GrandchildRouter(interactor: makeInteractor())
    let child = ChildRouter(interactor: makeInteractor(), grandchild: grandchild)
    let parent = ParentRouter(interactor: makeInteractor(), child: child)
    return (parent, child, grandchild)
  }

  private func makeInteractor() -> TCAInteractor<LifecycleFeature> {
    let store = Store(initialState: LifecycleFeature.State()) {
      LifecycleFeature()
    }
    return TCAInteractor(store: store)
  }

  private func cancellableTask(counter: StressCancellationCounter) -> Task<Void, Never> {
    Task {
      await withTaskCancellationHandler {
        while !Task.isCancelled {
          try? await Task.sleep(for: .milliseconds(10))
        }
      } onCancel: {
        Task { await counter.markCancelled() }
      }
    }
  }

  private func waitUntil(timeoutMilliseconds: Int, condition: @escaping @Sendable () async -> Bool) async {
    let deadline = ContinuousClock().now + .milliseconds(timeoutMilliseconds)
    while !(await condition()) && ContinuousClock().now < deadline {
      try? await Task.sleep(for: .milliseconds(20))
    }
  }

  actor StressCancellationCounter {
    private(set) var cancelledCount = 0

    func markCancelled() {
      cancelledCount += 1
    }
  }

  final class EphemeralParentRouter: BaseRouter {
    private let makeChild: () -> EphemeralChildRouter
    private(set) var childRouter: EphemeralChildRouter?

    init(makeChild: @escaping () -> EphemeralChildRouter) {
      self.makeChild = makeChild
      super.init()
    }

    func presentChildIfNeeded() {
      guard childRouter == nil else { return }
      let child = makeChild()
      childRouter = child
      attachChild(child)
    }

    func dismissChildIfNeeded() {
      guard let childRouter else { return }
      childRouter.dismissGrandchildIfNeeded()
      detachChild(childRouter)
      self.childRouter = nil
    }
  }

  final class EphemeralChildRouter: BaseRouter {
    private let makeGrandchild: () -> EphemeralGrandchildRouter
    private(set) var grandchildRouter: EphemeralGrandchildRouter?

    init(makeGrandchild: @escaping () -> EphemeralGrandchildRouter) {
      self.makeGrandchild = makeGrandchild
      super.init()
    }

    func presentGrandchildIfNeeded() {
      guard grandchildRouter == nil else { return }
      let grandchild = makeGrandchild()
      grandchildRouter = grandchild
      attachChild(grandchild)
    }

    func dismissGrandchildIfNeeded() {
      guard let grandchildRouter else { return }
      detachChild(grandchildRouter)
      self.grandchildRouter = nil
    }
  }

  final class EphemeralGrandchildRouter: BaseRouter {}
}
