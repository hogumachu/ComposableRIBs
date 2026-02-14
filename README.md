# ComposableRIBs

## What It Is
ComposableRIBs is an iOS-focused library that combines TCA for UI and business logic with RIB-style module structure. The goal is to keep state transitions and effects in reducers while using Builder, Router, Interactor, and Dependency contracts for composition and lifecycle management.

## Platform and Scope
- Target platform: iOS 17+.
- In scope host UI technologies: UIKit and SwiftUI.
- Out of scope: macOS and other non-iOS platforms.

## Architecture Boundary (TCA vs RIBs)
- TCA is responsible for `State`, `Action`, `Reducer`, and effect logic.
- RIB-style structure in this repository is responsible for composition and runtime wiring through `Buildable`, `Routing`, `Interactable`, and `RIBComponent`.
- `TCAInteractor` bridges both layers by forwarding lifecycle actions to reducers and cancelling managed runtime tasks when deactivating.
- Protocol-first module contracts are mandatory.
- Concrete dependency leakage across module boundaries is forbidden.
- Presentation state/action is TCA-owned; UIKit navigation side effects are router-owned.
- Upstream cross-module intent is delegate-first (`Action.delegate(...)`) when parent coordination is needed.
- Delegate channels are optional by default and should be introduced only where upstream signaling is required.

## Installation
Add ComposableRIBs with Swift Package Manager:

```swift
// Package.swift
.package(url: "https://github.com/hogumachu/ComposableRIBs.git", from: "0.1.0")
```

Then add the product to your target dependencies:

```swift
dependencies: [
  .product(name: "ComposableRIBs", package: "ComposableRIBs")
]
```

Minimum supported platform is iOS 17.

## Quick Start (Minimal Example)
```swift
import ComposableArchitecture
import ComposableRIBs

@Reducer
struct CounterFeature {
  @ObservableState
  struct State: Equatable {
    var count = 0
    var isActive = false
  }

  enum Action: Equatable, LifecycleActionConvertible {
    case incrementTapped
    case lifecycle(InteractorLifecycleAction)

    static func makeLifecycleAction(_ action: InteractorLifecycleAction) -> Self {
      .lifecycle(action)
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .incrementTapped:
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

@MainActor
func bootstrap() {
  let store = Store(initialState: CounterFeature.State()) {
    CounterFeature()
  }
  let interactor = TCAInteractor<CounterFeature>(store: store)

  interactor.activate()
  interactor.deactivate()
}
```

This snippet is a conceptual starter to show lifecycle wiring, not a full production module.

## Core Concepts
- `Buildable`: Defines how a module is built from a dependency contract into a routing root.
- `Routing` / `BaseRouter`: Defines and provides default child attachment/detachment behavior for router trees.
- `Interactable`: Defines activation and deactivation lifecycle hooks for runtime components.
- `RIBComponent`: Holds dependency contracts and limits concrete-type leakage across module boundaries.
- `LifecycleActionConvertible`: Converts shared interactor lifecycle events into each feature's concrete action type.
- `TCAInteractor`: Forwards lifecycle events to reducer actions and owns managed task cancellation.
- `LifecycleCaseActionConvertible`: Removes per-feature lifecycle forwarding boilerplate when action enums contain `case lifecycle(...)`.
- `ActionObservingReducer` + `ActionRelay`: Forward reducer action streams to router/interactor observers without coupling views to routers.
- `DelegateActionExtractable`: Optional contract for actions that expose upstream delegate events.
- `SwiftUIHostingRouter`: Centralizes store/interactor/view hosting and shared navigation lifecycle helpers.
- Protocol-first boundary rule: parent-child composition must use dependency contracts instead of concrete parent types.

## API Maturity (v0.x)
Core API (stable in v0.x):
- `Buildable`
- `Routing`
- `BaseRouter`
- `Interactable`
- `RIBComponent`
- `RIBDependency`

Bridge API (evolving in v0.x):
- `InteractorLifecycleAction`
- `LifecycleActionConvertible`
- Lifecycle bridge ergonomics around `TCAInteractor`
- Example composition patterns and integration guidance

Compatibility note: minor breaking changes may occur before 1.0 and will be documented in `CHANGELOG.md`.

## Testing
Current test focus includes:
- Router child attach/detach behavior
- Lifecycle forwarding
- Managed task cancellation
- Vertical wiring validation

Run tests with:

```bash
swift test
```

## Roadmap
See `docs/ROADMAP.md` for the v0.x delivery plan.

For a symbol-by-symbol boundary and stability table, see `docs/API_STABILITY.md`.
For protocol-first architectural constraints and enforcement rules, see `docs/ARCHITECTURE_GUARDRAILS.md`.
For a working iOS sample app (UIKit root + SwiftUI/TCA modules), see `Examples/iOSSample/README.md`.

## Contributing
Before contributing, read `AGENTS.md`.

Contributor requirements include:
- English-only contributor-facing writing
- Clear documentation and intent-level source comments
- Conventional Commit policy compliance

## License
This project is licensed under the MIT License.

See `LICENSE` for license terms and `CHANGELOG.md` for v0.x change history.
