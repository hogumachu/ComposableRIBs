# ComposableRIBs Project Rules

## Product Goal
- This library is iOS-first and combines RIBs architecture with TCA.
- UI and business logic must be implemented with SwiftUI + TCA.
- Router, Builder, Dependency, and structural composition must follow RIBs patterns implemented in this repository.

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

## Evolution Principles
- Start from minimal public primitives.
- Add higher-level convenience APIs only after core contracts are stable and tested.
- Every feature touching lifecycle bridge must include regression tests.

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

### Review Gate
- Changes that add or modify behavior should be rejected if:
  - required documentation updates are missing,
  - complex logic lacks intent-level comments,
  - or contributor-facing text is not written in English.
