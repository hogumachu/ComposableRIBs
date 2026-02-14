# Execution State

This file is the handoff source of truth for continuing work without relying on chat history.

## Last Completed
- Phase 3 contributor workflow milestone completed:
  - Added `CONTRIBUTING.md` with contributor workflow, review gates, validation commands, and architecture checklist.
  - Added `.github/PULL_REQUEST_TEMPLATE.md` with roadmap/API/architecture/test/doc verification fields.
  - Added issue templates under `.github/ISSUE_TEMPLATE/` for bug and feature intake quality.
  - Synced `README.md` and `docs/ROADMAP.md` to reflect contributor workflow baseline completion.
- Phase 1 usage-guide milestone completed:
  - Added `docs/MODULE_WIRING_GUIDE.md` with builder-first wiring flow, protocol-first boundary rules, and router lifetime guidelines.
  - Added `docs/LIFECYCLE_BRIDGE_GUIDE.md` with interactor-owned lifecycle/cancellation model and delegate-first action-observation guidance.
  - Linked both guides from `README.md`.
  - Synced roadmap status by marking Phase 1 item #3 complete in `docs/ROADMAP.md`.
- Pure TCA feature-action lifecycle decoupling completed:
  - Removed `InteractorLifecycleAction`, `LifecycleActionConvertible`, and `LifecycleCaseActionConvertible` from `Sources/ComposableRIBsTCA`.
  - Updated `TCAInteractor` and `SwiftUIHostingRouter` so features no longer need a shared lifecycle action case.
  - Migrated iOS sample features to pure TCA actions and moved child ticker runtime work to router/interactor-managed tasks.
  - Updated lifecycle-related tests and docs to reflect interactor-owned runtime lifecycle behavior.
  - Validation passed:
    - `xcodebuild -scheme ComposableRIBs -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test`
    - `xcodebuild -project Examples/iOSSample/iOSSample.xcodeproj -scheme iOSSample -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' build`
- Sample router lifetime hardening milestone completed:
  - Refactored sample Parent/Child routing to build dismissible child modules on demand.
  - Removed long-lived strong child/grandchild router retention and release child references on close.
  - Added architecture boundary checks for ephemeral child-router lifetime in `Tests/ComposableRIBsTests/ArchitectureBoundaryTests.swift`.
  - Added lifecycle/deinit regression coverage in `Tests/ComposableRIBsTests/ModuleLifecycleStressTests.swift`.
  - Validation passed:
    - `xcodebuild -scheme ComposableRIBs -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test -only-testing:ComposableRIBsTests/ArchitectureBoundaryTests`
    - `xcodebuild -scheme ComposableRIBs -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test -only-testing:ComposableRIBsTests/ModuleLifecycleStressTests`
    - `xcodebuild -project Examples/iOSSample/iOSSample.xcodeproj -scheme iOSSample -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' build`
- LaunchRouter pattern realignment completed:
  - Added additive launch abstractions in `ComposableRIBsCore`: `LaunchRouting` and `BaseLaunchRouter`.
  - Added UIKit launch implementation in `ComposableRIBsUI`: `UIKitLaunchRouter`.
  - Migrated sample app entry to `SceneDelegate -> LaunchRouting.launch(from:)` using `SampleLaunchRouter`.
  - Removed direct root feature router retention from `SceneDelegate` and now retain launch router only.
  - Updated architecture boundary tests to validate launch-router entry and retention pattern.
- Delegate-first upstream event direction milestone completed:
  - Added governance rules in `AGENTS.md` and `docs/ARCHITECTURE_GUARDRAILS.md` to prioritize `Action.delegate(...)` for upstream module intent.
  - Added additive bridge primitives in `ComposableRIBsTCA`: `ActionRelay`, `ActionObservingReducer`, and `DelegateActionExtractable`.
  - Extended `TCAInteractor` with optional action observation APIs and delegate-event observation helper.
  - Migrated iOS sample Parent -> Child -> Grandchild routing intents to delegate-first flow (router no longer polls `showX`/`shouldClose` flags).
  - Added delegate bridge tests in `Tests/ComposableRIBsTests/DelegateActionBridgeTests.swift`.
- Phase reorder + protocol-first abstraction milestone completed:
  - Moved open-source governance/release discipline work behind the new abstraction-focused phase.
  - Added `ComposableRIBsUI` target with `SwiftUIHostingRouter` and `RoutableViewControlling`.
  - Migrated sample module boundaries to protocol-based routing/building contracts.
  - Added hosting-router behavior tests and strengthened architecture boundary compile checks.
  - Validation passed:
    - `xcodebuild -scheme ComposableRIBs -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test`
    - `xcodebuild -project Examples/iOSSample/iOSSample.xcodeproj -scheme iOSSample -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' build`
- Phase 2 item #1 completed:
  - Added `LICENSE` with MIT terms (`Copyright (c) 2026 hogumachu`)
  - Added `CHANGELOG.md` using Keep a Changelog structure
  - Aligned `README.md` and `docs/ROADMAP.md` with license/changelog status
- Phase 1 integration edge/stress test hardening completed:
  - Added new nested edge-case coverage in `Tests/ComposableRIBsTests/VerticalSliceTests.swift`
  - Added stress scenarios in `Tests/ComposableRIBsTests/ModuleLifecycleStressTests.swift`
  - Re-ran focused suites twice consecutively to confirm non-flaky outcomes
  - Re-ran full package test suite on iOS simulator (`26 tests passed`)
- Protocol-first architecture guardrails milestone completed:
  - Added governance guardrail rules and protocol-first review gate in `AGENTS.md`
  - Added architecture guardrails reference in `docs/ARCHITECTURE_GUARDRAILS.md`
  - Updated `README.md` and `docs/ROADMAP.md` with protocol-first boundary policy
  - Added compile-oriented boundary tests in `Tests/ComposableRIBsTests/ArchitectureBoundaryTests.swift`
- iOS sample navigation realignment completed:
  - Views now depend on `StoreOf<Feature>` only (no router references in views)
  - Reducers now handle routing intents as state changes
  - UIKit routers now own `UINavigationController` push/pop and module attach/detach
  - Parent -> Child -> Grandchild flow remains intact with lifecycle activation/deactivation
- Phase 0 roadmap checklist synced and marked complete in `docs/ROADMAP.md`.
- Phase 1 sample bootstrap completed:
  - `Examples/iOSSample` project generated with UIKit root + SwiftUI host
  - Parent -> Child -> Grandchild module flow implemented
  - iOS simulator build validated
  - package test run validated via Xcode scheme (`17 tests passed`)
- Core API stabilization completed (access boundary + stability labeling):
  - commit `ba12222`
- README completed and repository URL aligned:
  - commit `df4fae2`
- Core test hardening completed (lifecycle, cancellation, routing, dependency wiring):
  - commit `68740fa`

## In Progress
- None.

## Next Action
1. Start Phase 3 item #2: define semantic versioning policy for v0.x.
2. Then complete Phase 3 item #3: document pre-release checklist and tag/release guidance.
3. Align contributor-facing docs so AGENTS governance rules are fully reflected for Phase 3 item #4.

## Known Blockers
- `swift test` in this environment still does not represent iOS-only package execution reliably.
- Preferred validation path remains `xcodebuild` on iOS simulator for this repository.

## Validation Commands
- Repository status:
  - `git status --short`
- Roadmap/status docs check:
  - `cat docs/ROADMAP.md`
  - `cat docs/EXECUTION_STATE.md`
- Usage guide presence and references:
  - `ls -la docs/MODULE_WIRING_GUIDE.md docs/LIFECYCLE_BRIDGE_GUIDE.md`
  - `rg -n "MODULE_WIRING_GUIDE|LIFECYCLE_BRIDGE_GUIDE" README.md docs/ROADMAP.md docs/EXECUTION_STATE.md`
- Contributor workflow docs and template presence:
  - `ls -la CONTRIBUTING.md .github/PULL_REQUEST_TEMPLATE.md .github/ISSUE_TEMPLATE`
  - `rg -n "CONTRIBUTING|PULL_REQUEST_TEMPLATE|ISSUE_TEMPLATE" README.md docs/ROADMAP.md docs/EXECUTION_STATE.md`
- License/changelog presence and references:
  - `ls -la LICENSE CHANGELOG.md`
  - `rg -n "LICENSE|CHANGELOG" README.md docs/ROADMAP.md docs/EXECUTION_STATE.md`
- iOS simulator package tests:
  - `xcodebuild -scheme ComposableRIBs -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test`
- Architecture boundary tests:
  - `xcodebuild -scheme ComposableRIBs -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test -only-testing:ComposableRIBsTests/ArchitectureBoundaryTests`
- Delegate action bridge tests:
  - `xcodebuild -scheme ComposableRIBs -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test -only-testing:ComposableRIBsTests/DelegateActionBridgeTests`
- Vertical slice edge-case tests:
  - `xcodebuild -scheme ComposableRIBs -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test -only-testing:ComposableRIBsTests/VerticalSliceTests`
- Lifecycle stress tests:
  - `xcodebuild -scheme ComposableRIBs -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test -only-testing:ComposableRIBsTests/ModuleLifecycleStressTests`
- iOS sample app build:
  - `xcodebuild -project Examples/iOSSample/iOSSample.xcodeproj -scheme iOSSample -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' build`

## Resume Checklist
1. Open this file first: `docs/EXECUTION_STATE.md`.
2. Confirm roadmap checkbox state: `docs/ROADMAP.md`.
3. Re-run validation command(s) and record blockers/results.
4. Start the next roadmap item and update this file in the same commit.
5. Keep commit scope focused (one milestone per commit where possible).
