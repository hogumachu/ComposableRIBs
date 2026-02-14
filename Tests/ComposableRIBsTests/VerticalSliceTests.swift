import ComposableArchitecture
import ComposableRIBs
import SwiftUI
import Testing

@MainActor
@Suite("Vertical Slice")
struct VerticalSliceTests {
  protocol CounterDependency: RIBDependency {
    var initialCount: Int { get }
  }

  struct AppDependency: CounterDependency {
    let initialCount: Int
  }

  protocol ChildDependency: RIBDependency {
    var startEnabled: Bool { get }
  }

  struct ParentDependency: ChildDependency {
    let startEnabled: Bool
    let parentOnlyValue: String
  }

  struct CounterBuilder: Buildable {
    func build(with dependency: AppDependency) -> CounterRouter {
      let store = Store(initialState: CounterFeature.State(count: dependency.initialCount)) {
        CounterFeature()
      }
      let interactor = TCAInteractor<CounterFeature>(store: store)
      return CounterRouter(interactor: interactor, store: store)
    }
  }

  struct ChildBuilder: Buildable {
    func build(with dependency: any ChildDependency) -> BaseRouter {
      let router = BaseRouter()
      if dependency.startEnabled {
        router.load()
      }
      return router
    }
  }

  final class CounterRouter: BaseRouter {
    let interactor: TCAInteractor<CounterFeature>
    let store: StoreOf<CounterFeature>

    init(interactor: TCAInteractor<CounterFeature>, store: StoreOf<CounterFeature>) {
      self.interactor = interactor
      self.store = store
    }
  }

  @Reducer
  struct CounterFeature {
    @ObservableState
    struct State: Equatable {
      var count: Int
      var isActive = false
    }

    enum Action: Equatable, LifecycleActionConvertible {
      case incrementButtonTapped
      case lifecycle(InteractorLifecycleAction)

      static func makeLifecycleAction(_ action: InteractorLifecycleAction) -> Self {
        .lifecycle(action)
      }
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .incrementButtonTapped:
          state.count += 1
          return .none
        case .lifecycle(.didBecomeActive):
          state.isActive = true
          return .none
        case .lifecycle(.willResignActive):
          state.isActive = false
          return .none
        }
      }
    }
  }

  struct CounterView: View {
    let store: StoreOf<CounterFeature>

    var body: some View {
      VStack {
        Text("\(store.count)")
        Button("+") {
          store.send(.incrementButtonTapped)
        }
      }
    }
  }

  @Test("Builder wires Router, Interactor, and TCA Store")
  func builderWiring() {
    let builder = CounterBuilder()
    let router = builder.build(with: AppDependency(initialCount: 2))
    let viewStore = ViewStore(router.store, observe: { $0 })

    router.interactor.activate()
    viewStore.send(.incrementButtonTapped)

    _ = CounterView(store: router.store)

    #expect(viewStore.count == 3)
    #expect(viewStore.isActive)
  }

  @Test("Builder can depend on dependency contracts instead of concrete parent types")
  func dependencyWiringUsesContracts() {
    let builder = ChildBuilder()
    let parent = ParentDependency(startEnabled: true, parentOnlyValue: "private")

    let router = builder.build(with: parent)

    #expect(type(of: router) == BaseRouter.self)
  }

  protocol RootDependency: RIBDependency {
    var initialValue: Int { get }
  }

  protocol MidDependency: RIBDependency {
    var multiplier: Int { get }
  }

  protocol LeafDependency: RIBDependency {
    var title: String { get }
  }

  struct RootAppDependency: RootDependency {
    let initialValue: Int
    let internalOnly: String
  }

  struct RootComponent: MidDependency {
    let dependency: any RootDependency
    var multiplier: Int { 2 }
  }

  struct MidComponent: LeafDependency {
    let dependency: any MidDependency
    var title: String { "Grandchild" }
  }

  @Reducer
  struct LifecycleFeature {
    @ObservableState
    struct State: Equatable {
      var isActive = false
      var value: Int
    }

    enum Action: Equatable, LifecycleActionConvertible {
      case lifecycle(InteractorLifecycleAction)

      static func makeLifecycleAction(_ action: InteractorLifecycleAction) -> Self {
        .lifecycle(action)
      }
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .lifecycle(.didBecomeActive):
          state.isActive = true
          return .none
        case .lifecycle(.willResignActive):
          state.isActive = false
          return .none
        }
      }
    }
  }

  final class RootRouter: BaseRouter {
    let interactor: TCAInteractor<LifecycleFeature>
    let store: StoreOf<LifecycleFeature>
    let child: MidRouter

    init(interactor: TCAInteractor<LifecycleFeature>, store: StoreOf<LifecycleFeature>, child: MidRouter) {
      self.interactor = interactor
      self.store = store
      self.child = child
      super.init()
      attachChild(child)
    }

    @MainActor
    func activateTree() {
      interactor.activate()
      child.interactor.activate()
      child.grandchild.interactor.activate()
    }

    @MainActor
    func deactivateTree() {
      child.grandchild.interactor.deactivate()
      child.interactor.deactivate()
      interactor.deactivate()
    }
  }

  final class MidRouter: BaseRouter {
    let interactor: TCAInteractor<LifecycleFeature>
    let store: StoreOf<LifecycleFeature>
    let grandchild: LeafRouter

    init(interactor: TCAInteractor<LifecycleFeature>, store: StoreOf<LifecycleFeature>, grandchild: LeafRouter) {
      self.interactor = interactor
      self.store = store
      self.grandchild = grandchild
      super.init()
      attachChild(grandchild)
    }
  }

  final class LeafRouter: BaseRouter {
    let interactor: TCAInteractor<LifecycleFeature>
    let store: StoreOf<LifecycleFeature>

    init(interactor: TCAInteractor<LifecycleFeature>, store: StoreOf<LifecycleFeature>) {
      self.interactor = interactor
      self.store = store
      super.init()
    }
  }

  struct LeafBuilder: Buildable {
    func build(with dependency: any LeafDependency) -> LeafRouter {
      let store = Store(initialState: LifecycleFeature.State(value: dependency.title.count)) {
        LifecycleFeature()
      }
      let interactor = TCAInteractor<LifecycleFeature>(store: store)
      return LeafRouter(interactor: interactor, store: store)
    }
  }

  struct MidBuilder: Buildable {
    let leafBuilder = LeafBuilder()

    func build(with dependency: any MidDependency) -> MidRouter {
      let component = MidComponent(dependency: dependency)
      let grandchild = leafBuilder.build(with: component)
      let store = Store(initialState: LifecycleFeature.State(value: dependency.multiplier)) {
        LifecycleFeature()
      }
      let interactor = TCAInteractor<LifecycleFeature>(store: store)
      return MidRouter(interactor: interactor, store: store, grandchild: grandchild)
    }
  }

  struct RootBuilder: Buildable {
    let midBuilder = MidBuilder()

    func build(with dependency: any RootDependency) -> RootRouter {
      let component = RootComponent(dependency: dependency)
      let child = midBuilder.build(with: component)
      let store = Store(initialState: LifecycleFeature.State(value: dependency.initialValue)) {
        LifecycleFeature()
      }
      let interactor = TCAInteractor<LifecycleFeature>(store: store)
      return RootRouter(interactor: interactor, store: store, child: child)
    }
  }

  @Test("Parent-child-grandchild routers are attached in a nested tree")
  func nestedRouterTreeAttachment() {
    let router = RootBuilder().build(with: RootAppDependency(initialValue: 1, internalOnly: "secret"))

    #expect(router.children.count == 1)
    #expect(router.child.children.count == 1)
    #expect(ObjectIdentifier(router.children[0]) == ObjectIdentifier(router.child))
    #expect(ObjectIdentifier(router.child.children[0]) == ObjectIdentifier(router.child.grandchild))
  }

  @Test("Nested lifecycle transitions propagate through each module interactor")
  func nestedLifecycleTransitions() {
    let router = RootBuilder().build(with: RootAppDependency(initialValue: 1, internalOnly: "secret"))
    let root = ViewStore(router.store, observe: { $0 })
    let mid = ViewStore(router.child.store, observe: { $0 })
    let leaf = ViewStore(router.child.grandchild.store, observe: { $0 })

    router.interactor.activate()
    router.child.interactor.activate()
    router.child.grandchild.interactor.activate()

    #expect(root.isActive)
    #expect(mid.isActive)
    #expect(leaf.isActive)

    router.child.grandchild.interactor.deactivate()
    router.child.interactor.deactivate()
    router.interactor.deactivate()

    #expect(!root.isActive)
    #expect(!mid.isActive)
    #expect(!leaf.isActive)
  }

  @Test("Nested managed task is cancelled when grandchild deactivates")
  func nestedGrandchildCancellation() async {
    let router = RootBuilder().build(with: RootAppDependency(initialValue: 1, internalOnly: "secret"))
    let probe = CancellationProbe()

    router.child.grandchild.interactor.manage(
      Task {
        await withTaskCancellationHandler {
          while !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(10))
          }
        } onCancel: {
          Task { await probe.markCancelled() }
        }
      }
    )

    router.child.grandchild.interactor.deactivate()

    for _ in 0..<80 where !(await probe.cancelled) {
      try? await Task.sleep(for: .milliseconds(10))
    }

    #expect(await probe.cancelled)
  }

  @Test("Repeated child route intent does not duplicate attachment")
  func repeatedChildAttachIntentDeduplicates() {
    let router = RootBuilder().build(with: RootAppDependency(initialValue: 1, internalOnly: "secret"))

    router.attachChild(router.child)
    router.attachChild(router.child)

    #expect(router.children.count == 1)
    #expect(ObjectIdentifier(router.children[0]) == ObjectIdentifier(router.child))
  }

  @Test("Detach order is safe when grandchild already detached")
  func detachOrderIsSafeForDetachedGrandchild() {
    let router = RootBuilder().build(with: RootAppDependency(initialValue: 1, internalOnly: "secret"))

    router.child.detachChild(router.child.grandchild)
    router.detachChild(router.child)
    router.child.detachChild(router.child.grandchild)

    #expect(router.children.isEmpty)
    #expect(router.child.children.isEmpty)
  }

  @Test("Deactivate parent cascades child/grandchild lifecycle to inactive")
  func deactivateCascadeKeepsNestedInactive() {
    let router = RootBuilder().build(with: RootAppDependency(initialValue: 1, internalOnly: "secret"))
    let root = ViewStore(router.store, observe: { $0 })
    let mid = ViewStore(router.child.store, observe: { $0 })
    let leaf = ViewStore(router.child.grandchild.store, observe: { $0 })

    router.activateTree()
    #expect(root.isActive)
    #expect(mid.isActive)
    #expect(leaf.isActive)

    router.deactivateTree()

    #expect(!root.isActive)
    #expect(!mid.isActive)
    #expect(!leaf.isActive)
  }

  @Test("Reactivation after nested teardown restores expected lifecycle sequence")
  func reactivationAfterTeardownRestoresSequence() {
    let router = RootBuilder().build(with: RootAppDependency(initialValue: 1, internalOnly: "secret"))
    let root = ViewStore(router.store, observe: { $0 })
    let mid = ViewStore(router.child.store, observe: { $0 })
    let leaf = ViewStore(router.child.grandchild.store, observe: { $0 })

    router.activateTree()
    router.deactivateTree()

    #expect(!root.isActive)
    #expect(!mid.isActive)
    #expect(!leaf.isActive)

    router.activateTree()

    #expect(root.isActive)
    #expect(mid.isActive)
    #expect(leaf.isActive)
  }
}
