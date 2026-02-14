# ComposableRIBs Project Rules

## Product Goal
- This library is iOS-first and combines RIBs architecture with TCA.
- UI and business logic must be implemented with SwiftUI + TCA.
- Router, Builder, Dependency, and structural composition must follow RIBs patterns implemented in this repository.
- Platform scope is iOS only (UIKit and SwiftUI). macOS and other Apple platforms are out of scope.

## Responsibility Split
- View: SwiftUI and TCA store-driven rendering.
- Reducer: TCA only; owns state transitions and business logic.
- Interactor: owns activation/deactivation lifecycle and external input bridging.
- Router: owns child attachment/detachment and module tree management.
- Builder: composes dependencies and wires Router/Interactor/Store/View.
- Dependency: explicit contracts only; child modules must not depend on parent concrete types.

## Interactor-Reducer Bridge Rules
- Interactor owns runtime lifecycle and must not require a shared lifecycle action case in every feature action enum.
- `activate()` should initialize interactor/router-owned runtime work when needed.
- `deactivate()` must cancel managed tasks and release runtime work tied to the active session.
- Long-running business effects are implemented in reducer effects, not inside Interactor.

## Non-Goals (v1)
- No codegen/template CLI.
- No high-level DSL abstraction yet.
- No support target below iOS 17.
- No macOS support.

## Evolution Principles
- Start from minimal public primitives.
- Add higher-level convenience APIs only after core contracts are stable and tested.
- Every feature touching lifecycle bridge must include regression tests.

## Protocol-First Architecture Guardrails
- Protocol-first module contracts are mandatory.
- Child builder inputs must be dependency protocols, never parent concrete types.
- Parent modules must not access child concrete internals beyond declared contracts.
- Router references must not cross feature boundaries except through routing contracts.
- SwiftUI views must depend on `StoreOf<Feature>` (or scoped stores), not router objects.
- Upstream cross-module intent should prefer `Action.delegate(...)` events when a module needs to notify its parent.
- Delegate channels are optional by default; do not add delegate boilerplate to modules that do not need upstream signaling.
- Reducers express intent and business state; routers execute UIKit navigation side effects.
- Child routers must not be held as long-lived strong properties when they represent dismissible flows.
- Dismissible child/grandchild modules should be built on demand and released (`nil`) after detach/pop unless a documented retention policy is required.
- Module boundaries must remain microservice-style:
  - communicate through contracts (protocols + actions/state),
  - keep implementation details private to each module boundary.

## Delegate-First Upstream Event Rule
- For parent-child module coordination, prefer delegate actions over router subscriptions to navigation-state flags.
- Recommended action shape:
  - `case childButtonTapped`
  - `case delegate(Delegate)`
  - nested `enum Delegate { ... }`
- Router and interactor should consume delegate events from action stream bridging rather than deriving transitions from `showX`/`shouldClose` flags.
- Prefer case-path delegate extraction in routers/interactors (for example, `observeDelegateEvents(for: \.delegate, ...)`) to avoid repetitive per-action extraction boilerplate.
- State-driven navigation flags are a fallback for modules that cannot reasonably introduce a delegate channel yet.

### Protocol-First Review Gate
- Reject changes when:
  - concrete dependency leakage crosses module boundaries,
  - view-router direct coupling is introduced,
  - upstream module coordination is implemented with state-flag polling when a delegate channel is feasible,
  - reducer code performs UIKit navigation side effects,
  - dismissible child routers are retained as long-lived strong references without an explicit documented reason,
  - architecture behavior changes without corresponding docs updates.

## Open Source Readiness: Writing & Comment Policy

- This project is being prepared for open-source release.
- All contributor-facing writing must be in English, including:
  - code comments,
  - documentation files,
  - pull request descriptions,
  - commit messages,
  - issue discussions and design notes.

### Documentation Standards
- Every new feature or architectural change must include clear documentation updates.
- Public APIs must be documented with purpose, inputs/outputs, and usage notes.
- Keep examples minimal, runnable, and aligned with current code.
- Prefer concise, high-signal explanations over long narrative text.
- Remove or update outdated docs in the same change that modifies behavior.

### Source Code Comment Standards
- Add comments where intent is not obvious from code alone.
- Explain why (design decision, constraint, tradeoff), not only what.
- For complex flows (especially Interactor ↔ Reducer bridging), document lifecycle expectations and cancellation behavior.
- Keep comments accurate and close to the code they describe.
- Do not add redundant comments that restate trivial code.
- When adding new source files, include enough comments for external contributors to understand responsibilities and extension points quickly.
- For newly added source code, add comments whenever behavior, constraints, or lifecycle intent may be unclear to readers.
- Public types and non-trivial public methods should include concise doc comments (`///`) by default.

### Review Gate
- Changes that add or modify behavior should be rejected if:
  - required documentation updates are missing,
  - complex logic lacks intent-level comments,
  - new source files are introduced without sufficient explanatory comments,
  - or contributor-facing text is not written in English.

## Commit Message Policy

- All commit messages must be written in English.
- Use Conventional Commits format for every commit:
  - `type(scope): subject`
  - Examples:
    - `feat(router): add child deduplication on attach`
    - `fix(interactor): cancel managed tasks on deactivate`
    - `docs(agents): add open-source writing policy`

### Allowed Types
- `feat`: new user-facing behavior
- `fix`: bug fix or regression fix
- `refactor`: structural change without behavior change
- `test`: add/update tests
- `docs`: documentation-only change
- `chore`: tooling/build/maintenance updates
- `ci`: CI workflow changes

### Subject Rules
- Use imperative mood (e.g., "add", "fix", "remove").
- Keep subject concise (recommended <= 72 characters).
- Do not end the subject with a period.
- The subject should describe what changed, not why it was difficult.

### Body Rules
- Add a body when context is needed.
- In the body, explain:
  - why the change is needed,
  - key design decisions/tradeoffs,
  - testing or verification performed.
- For behavior changes, include a short verification note.

### Commit Hygiene
- Keep each commit focused on one logical change.
- Avoid mixing refactor + behavior changes + docs in one commit unless tightly coupled.
- Ensure commit content matches the commit type and subject.
