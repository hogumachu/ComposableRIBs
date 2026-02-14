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

## API Maturity (v0.x)
Core API (stable in v0.x):
- `Buildable`
- `Routing`
- `Interactable`
- `RIBComponent`
- `RIBDependency`

Bridge API (evolving in v0.x):
- Lifecycle bridge ergonomics around `TCAInteractor`
- Example composition patterns and integration guidance

Compatibility note: minor breaking changes may occur before 1.0 and will be documented in changelog updates once `CHANGELOG.md` is introduced.

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
See `/Users/sungjun.hong/develop/ComposableRIBs/docs/ROADMAP.md` for the v0.x delivery plan.

## Contributing
Before contributing, read `/Users/sungjun.hong/develop/ComposableRIBs/AGENTS.md`.

Contributor requirements include:
- English-only contributor-facing writing
- Clear documentation and intent-level source comments
- Conventional Commit policy compliance

## License (Planned)
A license file is planned in the roadmap open-source readiness phase. The project does not declare a final license yet.
