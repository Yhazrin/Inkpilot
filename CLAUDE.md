# InkPilot — Engineering Constraints

## Code Style & Architecture

1. **Low coupling, high cohesion.** Each file has one clear responsibility. No god objects.
2. **Small composable SwiftUI views.** Extract repeated patterns into reusable components.
3. **Short files.** Target under 200–250 lines. Split at 300+.
4. **No code smells.** No copy-paste, no hard-coded strings, no magic numbers, no deeply nested bodies, no mock AI construction inside views.
5. **Services replaceable.** `MockSuggestionService` behind `SuggestionService` protocol. Views → ViewModel → Service.
6. **Design system reusable.** Shared visuals in `DesignSystem/`. Canvas rendering in `Canvas/`. AI schema/service in `AI/`. Stubs in `Recognition/`.
7. **Minimal but clean.** No overengineering, no unnecessary deps, no architecture frameworks.
8. **Refactor while building.** Extract repeated code immediately. Split large views. Centralize duplicated state. Rename vague names.
9. **Quality bar:** builds, PencilKit works, glass UI modular, mock AI service-driven, localization not hard-coded, a11y labels present, no large files, no scope creep.

## File Responsibility Map

| Directory | Responsibility |
|---|---|
| `App/` | App entry point only |
| `Screens/` | Screen-level views composing modules |
| `DesignSystem/` | Reusable visual primitives (tokens, glass, backgrounds) |
| `Canvas/` | Canvas state, PencilKit wrapper, canvas objects |
| `AI/` | Suggestion protocol, mock service, schema |
| `Recognition/` | OCR stubs for future integration |
| `Resources/` | Localization files, assets |

## What NOT to Do

- Do NOT put business logic in views
- Do NOT hard-code UI strings — use `String(localized:)` keys
- Do NOT scatter magic numbers — use `Brand` tokens
- Do NOT let any single file exceed 300 lines without splitting
- Do NOT build real OCR, LLM, paywall, account, PDF, or collaboration in V0.1
