# Architecture Guardrails

## Purpose
This document defines mandatory architecture guardrails for ComposableRIBs.

The project goal is:
- protocol-first RIB-style composition,
- dependency inversion across module boundaries,
- TCA-owned view/presentation state and business logic,
- UIKit router-owned navigation side effects.

## Protocol-First Rule
Protocol-based abstraction is the primary architectural constraint.

- Module boundaries must be expressed as contracts.
- Child modules consume dependency protocols only.
- Parent concrete types must not leak into child builder interfaces.
- Parent modules must not access child concrete internals.
- Concrete router type references across module boundaries are forbidden.
- Module wiring should use protocol contracts for both dependencies and routing outputs.

## Allowed vs Forbidden

| Area | Allowed | Forbidden |
| --- | --- | --- |
| Builder input | `ChildBuilder.build(with: any ChildDependency)` | `ChildBuilder.build(with: ParentConcreteDependency)` |
| View interaction | `store.send(...)` | `router.push(...)` / `router.present(...)` |
| Reducer responsibility | state/action/effect logic | UIKit navigation side effects |
| Router responsibility | push/pop/present/dismiss + attach/detach | business logic and state ownership |
| Module boundary | protocol contracts | concrete-type leakage across modules |

## Microservice-Style Module Boundary
Treat each feature module as an independently composable unit:

- Modules communicate through contracts (dependency protocols + action/state interfaces).
- Runtime composition happens in builders and routers.
- Concrete implementation details remain private inside each module boundary.
- Modules should be reusable without requiring parent concrete implementations.

## TCA and Router Boundary

### TCA-owned
- View rendering and intent dispatch.
- Reducer state transitions.
- Business effects and cancellation semantics.
- Upstream delegate intent emission (`Action.delegate(...)`) when parent coordination is required.

### Router-owned
- UIKit navigation side effects.
- Router tree attach/detach.
- Runtime wiring to child modules.
- Consuming delegate events from action streams and translating them to push/pop side effects.
- Prefer case-path delegate extraction in router/interactor wiring to avoid repeated extraction boilerplate.

## Sample Code Requirements
The sample app must continuously demonstrate the intended architecture:

1. Parent knows child contracts, not child concrete internals.
2. Views depend on stores, not routers.
3. Upstream cross-module intent is delegate-first (`Action.delegate(...)`), with state flags as fallback only.
4. Routers execute UIKit navigation from reducer/interactor delegate-event handling, preferably via case-path delegate extraction.
5. Default abstractions are mandatory unless a module includes a documented exception with rationale.
6. Prefer default bridge conveniences (for example, `TCAInteractor(initialState:reducer:)`) to reduce repetitive builder wiring unless an exception is documented.
7. App entry must use a launch router path (`SceneDelegate -> LaunchRouting.launch(from:)`) and `SceneDelegate` must retain the launch router strongly for runtime observer lifetime.

## Enforcement
Guardrails are enforced through both documentation and compile-oriented tests:

- Governance rules in `AGENTS.md`.
- Public architecture boundary in `README.md`.
- Roadmap tracking in `docs/ROADMAP.md`.
- Automated boundary checks in `Tests/ComposableRIBsTests/ArchitectureBoundaryTests.swift`.
