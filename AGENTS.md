# ComposableRIBs Project Rules

## Product Goal
- This library is iOS-first and combines RIBs architecture with TCA.
- UI and business logic must be implemented with SwiftUI + TCA.
- Router, Builder, Dependency, and structural composition must follow RIBs patterns implemented in this repository.
- Platform scope is iOS only (UIKit and SwiftUI). macOS and other Apple platforms are out of scope.

## Responsibility Split
- View: SwiftUI and TCA store-driven rendering.
- Reducer: TCA only; owns state transitions and business logic.
- Interactor: bridges lifecycle and external inputs to reducer actions.
- Router: owns child attachment/detachment and module tree management.
- Builder: composes dependencies and wires Router/Interactor/Store/View.
- Dependency: explicit contracts only; child modules must not depend on parent concrete types.

## Interactor-Reducer Bridge Rules
- Interactor owns lifecycle forwarding to TCA actions.
- `activate()` must emit `.lifecycle(.didBecomeActive)`.
- `deactivate()` must emit `.lifecycle(.willResignActive)` and cancel managed tasks.
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
- Reducers express navigation intent as state/action changes; routers execute UIKit navigation side effects.
- Module boundaries must remain microservice-style:
  - communicate through contracts (protocols + actions/state),
  - keep implementation details private to each module boundary.

### Protocol-First Review Gate
- Reject changes when:
  - concrete dependency leakage crosses module boundaries,
  - view-router direct coupling is introduced,
  - reducer code performs UIKit navigation side effects,
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
