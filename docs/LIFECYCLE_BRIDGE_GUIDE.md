# Lifecycle Bridge Guide

## Purpose
This guide defines how runtime lifecycle is owned by interactor/router layers while reducers remain focused on state transitions and business behavior.

## Lifecycle Ownership
`TCAInteractor` owns runtime lifecycle entry and exit:

1. `activate()` starts runtime wiring for the module.
2. `deactivate()` stops runtime wiring and cancels managed tasks.
3. Routers coordinate module visibility and navigation transitions.

Required close sequence for dismissible modules:

1. `interactor.deactivate()`
2. `detachChild(...)`
3. UIKit transition (`pop` or `dismiss`)
4. Release retained child reference (`nil`)

This ordering prevents leaked observers/tasks and aligns module lifetime with visible UI lifetime.

## User-Driven Navigation Auto-Sync
`SwiftUIHostingRouter` now supports automatic lifecycle synchronization when UIKit closes a screen directly:

1. Back button or swipe-back pop (`removedFromParent`)
2. Interactive modal swipe-down or direct dismiss (`dismissed`)

Use router helpers to keep cleanup idempotent:

- `attachActivateAndPush(_:in:animated:onRelease:)`
- `deactivateDetachAndPop(_:in:to:animated:onRelease:)`
- `attachActivateAndPresent(_:from:animated:onRelease:completion:)`
- `deactivateDetachAndDismiss(_:animated:onRelease:completion:)`
- `deactivateDetachAndReleaseIfNeeded(_:onRelease:)`

`onRelease` should clear retained child references (`childRouter = nil`) so dismissible modules are collectible after close.
Prefer registering `onRelease` at attach/present time so user-driven and programmatic close paths share one release callback.

## Action Observation and Delegate-First
Use action observation for upstream module intent:

- Prefer `observeAction(for: \.delegate, ...)` when a feature needs parent coordination.
- Keep delegate channels optional. Do not add delegate boilerplate to modules that do not need upstream signaling.
- Treat state-driven routing flags as fallback guidance, not the default architecture path.

Responsibilities:

1. View sends feature actions only.
2. Reducer expresses intent and state transitions.
3. Router/interactor observe actions and execute UIKit side effects.

## Cancellation Model
`TCAInteractor` must cancel managed tasks on deactivation.

Expected outcomes:

1. No long-running task survives module close.
2. Reopen creates a fresh runtime lifecycle for dismissible modules.
3. Reopen starts from fresh module instances, so module-owned runtime state is reset unless explicitly persisted outside the module.

## Testing Matrix
Use this baseline matrix for lifecycle bridge confidence:

1. Lifecycle forwarding
   - activation/deactivation hooks are invoked in expected order.
2. Cancellation leak checks
   - managed tasks are cancelled on deactivate.
   - repeated open/close cycles do not accumulate live tasks.
3. Reopen identity reset
   - child/grandchild routers are deallocated after close.
   - reopen creates new identities and expected fresh runtime state.
4. Nested router detach safety
   - duplicate attach is prevented.
   - detach of non-existent child is no-op safe.

## Troubleshooting
### `[weak self]` becomes `nil` in action observers
Likely cause:

- Root or parent router lifetime is not retained strongly by the app entry path.

Fix:

1. Use launch-router app entry (`SceneDelegate -> launchRouter.launch(from:)`).
2. Retain launch router strongly in `SceneDelegate`.

### Duplicate attach or unexpected repeated push
Likely cause:

- Missing guard before child creation/attachment.

Fix:

1. Guard with `childRouter == nil` (or equivalent identity check) before attach.
2. Keep attach/detach and push/pop flows in paired router methods.
