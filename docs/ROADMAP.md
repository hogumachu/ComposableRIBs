# ComposableRIBs Roadmap (v0.x)

## Scope and Principles
- This roadmap defines the v0.x path for ComposableRIBs as an iOS-only library.
- Product boundary: use TCA for UI and business logic; use RIB-style structure for module composition, routing, lifecycle, and dependency wiring.
- Focus on pragmatic, testable milestones that improve API stability and open-source readiness.
- Prioritize clear documentation, maintainable code comments, and contributor-friendly processes.

## Current Status (as of 2026-02-14)
- Core primitives and TCA lifecycle bridge are bootstrapped.
- Initial tests cover routing basics, lifecycle forwarding, cancellation behavior, and a vertical-slice wiring flow.
- Project governance rules exist in `AGENTS.md` (documentation/comment policy, commit policy, iOS-only scope).
- Public API maturity and contributor-facing documentation are now defined for v0.x.
- Phase 0 (v0.1.0 target) is complete as of 2026-02-14.
- Phase 1 sample bootstrap is in place with UIKit root hosting SwiftUI and a Parent -> Child -> Grandchild flow.
- Sample realignment completed: views/reducers use pure TCA patterns while UIKit routers own push/pop navigation and module attach/detach.

## Phase 0 — Foundation Hardening (v0.1.0 target)
### Objective
Solidify the core architecture, clarify public API expectations, and establish baseline documentation and test confidence.

### Deliverables
1. [x] Add `README.md` with architecture boundary, iOS-only scope (UIKit/SwiftUI), and quick-start integration.
2. [x] Review naming and access control for `Buildable`, `Routing`, `Interactable`, `RIBComponent`, and `TCAInteractor`.
3. [x] Mark APIs as stable vs subject-to-change during v0.x in docs.
4. [x] Expand core test coverage for lifecycle forwarding, cancellation edge cases, router invariants, and dependency wiring.
5. [x] Verify package and docs consistently declare iOS-only support with no macOS promises.

### Acceptance Criteria
1. `README.md` enables first-time setup without requiring source-code deep dives.
2. Core public APIs have documented intent and consistent access levels.
3. Stability notes exist for all major public entry points.
4. Core test suite covers agreed lifecycle/cancellation/router/dependency scenarios and passes in CI.
5. No repository document conflicts with iOS-only platform scope.

### Dependencies
- Existing core/TCA bridge implementation in `Sources/`.
- Existing governance policy in `AGENTS.md`.

### Risks / Mitigations
- Risk: API names may churn while features evolve.
  Mitigation: define stability labels early and record rationale in docs.
- Risk: gaps in lifecycle/cancellation coverage may hide regressions.
  Mitigation: prioritize regression tests before expanding feature surface.

## Phase 1 — Developer Experience and Adoption (v0.2.0 target)
### Objective
Make the library easier to evaluate and adopt through realistic examples, stronger guides, and deeper integration testing.

### Deliverables
1. [x] Add sample app(s) demonstrating parent-child RIB flow on iOS.
2. [x] Include both SwiftUI-first and UIKit-host integration examples (still iOS-only).
3. [ ] Publish usage documentation: module wiring guide and lifecycle bridge guide.
4. [ ] Add edge-case integration tests for multi-module flows.
5. [ ] Add concurrency/lifecycle stress scenarios to detect cancellation and activation ordering issues.

### Acceptance Criteria
1. Sample app builds and demonstrates modular navigation plus lifecycle transitions.
2. Integration examples show clear, reproducible setup for SwiftUI and UIKit hosting.
3. Guides explain how to connect Builder/Router/Interactor/TCA Store without ambiguity.
4. Integration and stress tests consistently pass and catch intentional failure injections.
5. Onboarding time for a new contributor is reduced by docs and examples.

### Dependencies
- Phase 0 API and documentation baseline.
- A stable enough core API to support sample usage without frequent rewrites.

### Risks / Mitigations
- Risk: sample apps drift from real library APIs.
  Mitigation: keep sample apps in the same repo and update within each API change.
- Risk: integration tests become flaky under concurrency stress.
  Mitigation: isolate shared state, keep deterministic scheduling where possible, and document known limitations.

## Phase 2 — Stability and Open-Source Readiness (v0.3.0 target)
### Objective
Finalize release discipline and repository hygiene required for reliable open-source collaboration.

### Deliverables
1. [ ] Add `LICENSE` and `CHANGELOG.md`.
2. [ ] Add contributor workflow documentation (issue/PR expectations and review quality gate).
3. [ ] Define semantic versioning policy for v0.x.
4. [ ] Document pre-release checklist and tag/release guidance.
5. [ ] Ensure AGENTS rules are reflected in contributor-facing docs.

### Acceptance Criteria
1. Repository includes standard legal and release-tracking files.
2. Contributors can follow documented workflow without tribal knowledge.
3. Versioning and release steps are explicit and repeatable.
4. Pre-release checks cover docs, tests, and API-impact review.
5. Governance rules and contributor docs are aligned without contradiction.

### Dependencies
- Phase 0 and 1 outputs (stable docs baseline, validated examples, reliable tests).

### Risks / Mitigations
- Risk: governance standards exist but are not enforced consistently.
  Mitigation: add explicit review checklist items and enforce in PR reviews.
- Risk: release process remains implicit.
  Mitigation: codify release playbook and use it for each v0.x cut.

## Out of Scope for v0.x
- Support for non-iOS platforms.
- Code generation/template CLI.
- High-level DSL abstractions before core API stabilization.

## Exit Criteria for v1.0
1. Public API surface is stable with migration notes for all v0.x breaking changes.
2. Documentation is mature: quick start, architecture reference, and end-to-end examples.
3. Lifecycle and cancellation confidence is high through broad deterministic test coverage.
4. Release workflow is predictable, repeatable, and contributor-friendly.
5. Contributor guidelines and governance rules are aligned and consistently applied.
