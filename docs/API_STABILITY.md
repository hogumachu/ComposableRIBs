# API Stability Matrix (v0.x)

This document defines the current public API boundary, intended audience, and stability level for v0.x.

## Stability Labels
- `stable-v0x`: Intended for external use with conservative change policy during v0.x.
- `evolving-v0x`: Publicly available but still expected to evolve before 1.0.

## Matrix

| Symbol | Current Access | Proposed Access | Stability Label | Audience | Rationale |
|---|---|---|---|---|---|
| `Buildable` | `public protocol` | `public protocol` | `stable-v0x` | External consumers | Core module construction contract. |
| `Routing` | `public protocol` | `public protocol` | `stable-v0x` | External consumers | Core router tree contract. |
| `BaseRouter` | `open class` | `open class` | `stable-v0x` | External consumers | Designed for extension/custom router behavior. |
| `Interactable` | `public protocol` | `public protocol` | `stable-v0x` | External consumers | Core lifecycle contract. |
| `RIBComponent` | `open class` | `public class` | `stable-v0x` | External consumers | Subclassing is not required for current dependency container role. |
| `RIBDependency` | `public protocol` | `public protocol` | `stable-v0x` | External consumers | Marker dependency contract used across modules. |
| `InteractorLifecycleAction` | `public enum` | `public enum` | `evolving-v0x` | External consumers | Bridge event shape may evolve with lifecycle ergonomics. |
| `LifecycleActionConvertible` | `public protocol` | `public protocol` | `evolving-v0x` | External consumers | Bridge mapping contract may evolve before 1.0. |
| `LifecycleCaseActionConvertible` | `public protocol` | `public protocol` | `evolving-v0x` | External consumers | Boilerplate-reduction helper for lifecycle action enums. |
| `TCAInteractor` | `open class` | `public final class` | `evolving-v0x` | External consumers | Lifecycle bridge remains public; customization surface is intentionally narrowed for now. |
| `RoutableViewControlling` | `public protocol` | `public protocol` | `evolving-v0x` | External consumers | Unifies view-controller backed routing contracts. |
| `SwiftUIHostingRouter` | `open class` | `open class` | `evolving-v0x` | External consumers | Shared SwiftUI/UIKit hosting base for router ergonomics. |

## Notes
- This matrix is aligned with `README.md` API maturity sections.
- Any stability-label or access changes should update this file and README in the same change.
