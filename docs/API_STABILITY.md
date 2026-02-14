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
| `DelegateActionExtractable` | `public protocol` | `public protocol` | `evolving-v0x` | External consumers | Legacy-compatible delegate extraction contract; retained during v0.x migration to case-path observation. |
| `ActionRelay` | `public final class` | `public final class` | `evolving-v0x` | External consumers | Action-stream relay used by interactor/router observation paths. |
| `ActionObservingReducer` | `public struct` | `public struct` | `evolving-v0x` | External consumers | Reducer wrapper that forwards all processed actions to observers. |
| `TCAInteractor` | `open class` | `public final class` | `evolving-v0x` | External consumers | Interactor runtime bridge remains public; includes managed task lifecycle ownership, delegate observation API (`observeDelegateEvents(for:_:)`), and convenience initializer for builder wiring simplification. |
| `RoutableViewControlling` | `public protocol` | `public protocol` | `evolving-v0x` | External consumers | Unifies view-controller backed routing contracts. |
| `SwiftUIHostingRouter` | `open class` | `open class` | `evolving-v0x` | External consumers | Shared SwiftUI/UIKit hosting base for router ergonomics. |
| `LaunchRouting` | `public protocol` | `public protocol` | `evolving-v0x` | External consumers | Standard launch entry contract for app-level routing coordination. |
| `BaseLaunchRouter` | `open class` | `open class` | `evolving-v0x` | External consumers | Base launch coordinator that owns root router load/launch lifecycle hooks. |
| `UIKitLaunchRouter` | `open class` | `open class` | `evolving-v0x` | External consumers | UIKit launch implementation that hosts root routing in a navigation controller and activates interactor lifecycle. |

## Notes
- This matrix is aligned with `README.md` API maturity sections.
- Any stability-label or access changes should update this file and README in the same change.
