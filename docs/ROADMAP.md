# ComposableRIBs Roadmap (v0.x)

## Scope and Principles
- This roadmap defines the v0.x path for ComposableRIBs as an iOS-only library.
- Product boundary: use TCA for UI and business logic; use RIB-style structure for module composition, routing, lifecycle, and dependency wiring.
- Focus on pragmatic, testable milestones that improve API stability and open-source readiness.
- Prioritize clear documentation, maintainable code comments, and contributor-friendly processes.

## Current Status (as of 2026-02-14)
- Core primitives and TCA interactor bridge are bootstrapped.
- Initial tests cover routing basics, lifecycle management, cancellation behavior, and a vertical-slice wiring flow.
- Project governance rules exist in `AGENTS.md` (documentation/comment policy, commit policy, iOS-only scope).
- Public API maturity and contributor-facing documentation are now defined for v0.x.
- Phase 0 (v0.1.0 target) is complete as of 2026-02-14.
- Phase 1 sample bootstrap is in place with UIKit root hosting SwiftUI and a Parent -> Child -> Grandchild flow.
- Sample realignment completed: views/reducers use pure TCA patterns while UIKit routers own push/pop navigation and module attach/detach.
- Protocol-first architecture guardrails are now documented with compile-oriented boundary tests.
- Roadmap priority updated: protocol-first abstraction and boilerplate reduction now precede open-source process hardening.
- License and changelog baseline are maintained as completed readiness artifacts and carried into later release-governance phase.
- Phase 2 abstraction milestone completed: protocol-first module contracts and shared hosting/lifecycle boilerplate reductions are validated.
- Delegate-first upstream event channel is now implemented for the sample flow, with state-flag routing reduced to fallback guidance.
- Sample router lifetime realignment completed: dismissible child/grandchild modules are now created on demand and released on close, with deinit-focused lifecycle regression coverage.
- Phase 1 usage guides completed: module wiring and lifecycle bridge documentation are now published.

## Phase 0 — Foundation Hardening (v0.1.0 target)
### Objective
Solidify the core architecture, clarify public API expectations, and establish baseline documentation and test confidence.

### Deliverables
1. [x] Add `README.md` with architecture boundary, iOS-only scope (UIKit/SwiftUI), and quick-start integration.
2. [x] Review naming and access control for `Buildable`, `Routing`, `Interactable`, `RIBComponent`, and `TCAInteractor`.
3. [x] Mark APIs as stable vs subject-to-change during v0.x in docs.
4. [x] Expand core test coverage for lifecycle management, cancellation edge cases, router invariants, and dependency wiring.
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
3. [x] Publish usage documentation: module wiring guide and lifecycle bridge guide.
4. [x] Add edge-case integration tests for multi-module flows.
5. [x] Add concurrency/lifecycle stress scenarios to detect cancellation and activation ordering issues.
6. [x] Document and enforce protocol-first architecture guardrails across AGENTS/README/docs.
7. [x] Add compile-oriented boundary tests for concrete leakage prevention and view-router coupling checks.

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

## Phase 2 — Protocol-First Abstraction and Ergonomics (v0.3.0 target)
### Objective
Reduce repetitive module wiring and enforce protocol-oriented boundaries so feature modules remain abstract, composable, and decoupled.

### Deliverables
1. [x] Enforce protocol-first routing/building contracts for module boundaries (no parent-child concrete type coupling).
2. [x] Add additive default/base abstractions for router hosting and interactor wiring ergonomics.
3. [x] Migrate sample app module wiring to contract-driven boundaries using the new abstractions.
4. [x] Validate boilerplate reduction with an explicit checklist and sample before/after simplification notes.
5. [x] Add compile and integration tests covering abstraction invariants and lifecycle/navigation helper behavior.
6. [x] Introduce delegate-first upstream event channels and migrate sample navigation intents away from state-flag polling.
7. [x] Add deinit/lifecycle regression coverage for dismissible child-router lifetime (close/reopen behavior).

### Acceptance Criteria
1. Parent/child and child/grandchild boundaries are expressed through protocol contracts only.
2. Repeated router/store/interactor hosting boilerplate is consolidated into shared abstractions.
3. Sample still demonstrates UIKit-owned navigation and TCA-owned state/action responsibilities.
4. Abstraction behavior is covered by compile-oriented and integration tests that pass in CI.
5. No breaking API changes are introduced while improving developer ergonomics.
6. Upstream parent-child coordination is delegate-first by default, with state flags treated as fallback guidance only.
7. Dismissible child modules are released on close and recreated on reopen, validated by lifecycle/deinit-focused tests.

### Dependencies
- Phase 0 and 1 outputs (validated sample flow and reliable lifecycle/cancellation tests).

### Risks / Mitigations
- Risk: abstraction additions may unintentionally hide navigation side effects.
  Mitigation: keep explicit router-owned transition methods and test lifecycle + navigation sync paths.
- Risk: protocolization without boundaries can still leak concrete types in builders.
  Mitigation: add compile-oriented boundary checks for builder and router contracts.

## Phase 3 — Stability and Open-Source Readiness (v0.4.0 target)
### Objective
Finalize release discipline and repository hygiene required for reliable open-source collaboration.

### Deliverables
1. [ ] Add contributor workflow documentation (issue/PR expectations and review quality gate).
2. [ ] Define semantic versioning policy for v0.x.
3. [ ] Document pre-release checklist and tag/release guidance.
4. [ ] Ensure AGENTS rules are reflected in contributor-facing docs.
5. [x] Keep `LICENSE` and `CHANGELOG.md` maintained as project baselines.

### Acceptance Criteria
1. Contributors can follow documented workflow without tribal knowledge.
2. Versioning and release steps are explicit and repeatable.
3. Pre-release checks cover docs, tests, and API-impact review.
4. Governance rules and contributor docs are aligned without contradiction.
5. Release discipline is documented independently from implementation details.

### Dependencies
- Completed Phase 2 abstraction work and stable contributor-facing examples.

### Risks / Mitigations
- Risk: governance standards exist but are not enforced consistently.
  Mitigation: add explicit review checklist items and enforce in PR reviews.
- Risk: release process remains implicit.
  Mitigation: codify release playbook and use it for each tagged release.

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
