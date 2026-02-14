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
}
