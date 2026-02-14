# Contributing to ComposableRIBs

Thank you for contributing to ComposableRIBs.

This project is iOS-only and combines TCA for UI/business logic with RIB-style composition for routing, lifecycle, and dependency wiring. Contributions should preserve that boundary.

## 1. Project Scope and Architecture Boundary

- Platform scope is iOS 17+ only (UIKit and SwiftUI).
- View layer is store-driven SwiftUI.
- Reducers own state transitions and business logic.
- Routers own UIKit navigation side effects and module tree changes.
- Builders compose dependencies and wire module boundaries.
- Interactors own runtime lifecycle and external runtime input bridging.

## 2. Development Prerequisites

- Xcode 26.x (or newer compatible version)
- iOS Simulator runtime available (project validation uses iPhone 16 / iOS 18.5 in examples)
- Swift Package Manager support through Xcode

## 3. Branch and Commit Policy

- Use focused branches per milestone or logical change.
- Keep each commit scoped to one logical unit.
- Commit messages must be in English and follow Conventional Commits:
  - `type(scope): subject`
  - Example: `fix(router): release child routing reference on close`

## 4. Pull Request Workflow

1. Start from an up-to-date main branch.
2. Implement one scoped change.
3. Run required validation commands.
4. Update docs in the same change when behavior or architecture guidance changes.
5. Open a PR using the repository PR template.

## 5. Review Quality Gate (Reject Criteria)

Reject changes if any of the following is true:

- Concrete dependency leakage crosses module boundaries.
- Views reference routers directly.
- Reducers perform UIKit navigation side effects.
- Dismissible child routers are retained long-term without explicit documented reason.
- Architecture behavior changes without matching doc updates.
- Contributor-facing text is not English.

## 6. Testing and Validation Commands

Preferred validation path is `xcodebuild` on iOS simulator.

```bash
git status --short
xcodebuild -scheme ComposableRIBs -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test
xcodebuild -scheme ComposableRIBs -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test -only-testing:ComposableRIBsTests/ArchitectureBoundaryTests
xcodebuild -project Examples/iOSSample/iOSSample.xcodeproj -scheme iOSSample -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' build
```

## 7. Documentation and Comment Requirements

- All contributor-facing writing must be in English.
- Update docs whenever architecture or behavior changes.
- Add intent-level comments for non-obvious logic and lifecycle-sensitive code.
- Keep comments concise, accurate, and close to the code they explain.

## 8. Architecture Guardrail Checklist

Before opening a PR, confirm:

- [ ] Parent-child module boundaries are protocol-first.
- [ ] Views are store-only and do not hold router references.
- [ ] Router owns UIKit navigation side effects.
- [ ] Delegate-first upstream signaling is used when parent coordination is needed.
- [ ] Dismissible child modules are built on demand and released on close.
- [ ] No absolute personal file paths were added to docs.

## 9. Release-Impact Checklist

Use this section to prepare future release discipline milestones:

- [ ] Public API impact identified (none/additive/breaking).
- [ ] Changelog impact identified.
- [ ] Migration note needed for existing adopters.
- [ ] Validation evidence recorded in PR.
