# InkPilot V0.1 Implementation Plan

This document captures the implementation plan produced from reading the current repository and the `InkPilot_V0.1_Codex_Master_Prompt.md` reference.

## 1. Existing Project Structure

Current workspace contents:

- `InkPilot_V0.1_Codex_Master_Prompt.md`

Current findings:

- No `.git` repository yet
- No Xcode project
- No Swift package
- No SwiftUI or UIKit source files
- No existing module layout to integrate with

Conclusion:

The workspace is effectively a bootstrap project folder containing the product specification only.

## 2. App Entry Point

There is no existing app entry point.

Missing today:

- `InkPilotApp.swift`
- `.xcodeproj`
- `.xcworkspace`
- `Package.swift`

Recommendation:

Create a new iPadOS-first SwiftUI app and use `InkPilotApp.swift` as the app entry point.

## 3. New Feature Module vs App Replacement

Recommendation:

Treat InkPilot V0.1 as a new app bootstrap, not as a feature module and not as an app replacement.

Reasoning:

- There is no existing app shell to preserve
- There is no current entry point to extend
- The prompt explicitly asks for a careful integration decision, and the repository state indicates greenfield setup

If hidden project files appear later outside this workspace root, re-evaluate before replacing anything.

## 4. Recommended File Structure

```text
InkPilot/
├── InkPilot.xcodeproj
├── InkPilot/
│   ├── App/
│   │   └── InkPilotApp.swift
│   ├── Screens/
│   │   ├── HomeView.swift
│   │   └── CanvasView.swift
│   ├── DesignSystem/
│   │   ├── BrandTokens.swift
│   │   ├── ColorBlockBackground.swift
│   │   ├── GlassCard.swift
│   │   ├── GlassCapsule.swift
│   │   ├── FloatingToolbar.swift
│   │   ├── FloatingPromptCapsule.swift
│   │   ├── FloatingPanel.swift
│   │   ├── AIBadge.swift
│   │   └── MotionTokens.swift
│   ├── Canvas/
│   │   ├── CanvasViewModel.swift
│   │   ├── CanvasTransform.swift
│   │   ├── CanvasObject.swift
│   │   ├── CanvasObjectLayer.swift
│   │   ├── AIOverlayLayer.swift
│   │   ├── FloatingChromeLayer.swift
│   │   ├── GhostSuggestionCard.swift
│   │   └── PencilKitCanvasRepresentable.swift
│   ├── AI/
│   │   ├── SuggestionSchema.swift
│   │   ├── SuggestionService.swift
│   │   ├── MockSuggestionService.swift
│   │   └── CanvasContextBuilder.swift
│   ├── Recognition/
│   │   ├── InkSnapshotRenderer.swift
│   │   └── VisionOCRService.swift
│   └── Resources/
│       └── Localizable.xcstrings
```

Notes:

- `Recognition/` should be stubs only in V0.1
- Avoid introducing real OCR or real LLM dependencies in the first pass
- Keep glass UI reusable and separate from the canvas interaction layer

## 5. Risk Areas

### PencilKit

Main risk:

SwiftUI gesture wrappers can interfere with normal `PKCanvasView` drawing behavior.

Guidance:

- Let Apple Pencil drawing take priority
- Isolate PencilKit in `PencilKitCanvasRepresentable`
- Keep the first pass focused on reliable pen input and simple eraser switching

### Gestures

Main risk:

Infinite-canvas pan and zoom, object dragging, tap targets, and PencilKit input can conflict with each other.

Guidance:

- Prioritize drawing stability over gesture richness
- Keep UI taps reliable
- Make card dragging optional if conflicts appear
- Do not block V0.1 on perfect infinite canvas gestures

### Localization

Main risk:

Visible strings can easily end up hard-coded in SwiftUI during prototyping, making English and Simplified Chinese support messy later.

Guidance:

- Start with `Localizable.xcstrings`
- Localize all visible copy from day one
- Keep labels short enough for floating UI
- Check both English and Simplified Chinese layouts early

### State Management

Main risk:

Canvas tool state, AI suggestion state, accepted cards, floating UI state, and future transform state can become fragmented across views.

Guidance:

- Use a single lightweight `CanvasViewModel` for V0.1
- Keep it responsible for:
  - current tool
  - ghost suggestion state
  - accepted canvas objects
  - AI panel state
  - selected object
  - injected suggestion service
  - basic transform state if needed

### Liquid Glass Styling

Main risk:

Latest iPadOS-specific visual APIs may not be available or stable for the chosen deployment target.

Guidance:

- Use SwiftUI materials as fallback
- Prefer calm translucency over flashy glassmorphism
- Keep shadows and borders restrained

## 6. Exact First-Pass Task List for Claude Code

1. Confirm the workspace still contains only planning/reference files.
2. Initialize a new iPadOS SwiftUI Xcode project named `InkPilot`.
3. Set the app entry point to `InkPilotApp.swift`.
4. Build `HomeView` with localized title, subtitle, and `New AI Canvas` CTA.
5. Build `CanvasView` as the main product surface.
6. Add `ColorBlockBackground` for the spatial backdrop.
7. Add reusable glass components:
   - `GlassCard`
   - `GlassCapsule`
   - `FloatingPanel`
   - `AIBadge`
8. Add top floating toolbar:
   - Pen
   - Eraser
   - Lasso placeholder
   - AI button
9. Add bottom floating prompt capsule with localized placeholder text.
10. Add compact AI Pilot floating panel with localized mock content.
11. Add `PencilKitCanvasRepresentable` backed by `PKCanvasView`.
12. Wire pen mode and basic eraser mode if feasible.
13. Add data models:
   - `CanvasObject`
   - `CanvasTransform`
   - Codable point/size wrappers if needed
14. Add `SuggestionService` protocol.
15. Add `MockSuggestionService` returning the fixed demo suggestion.
16. Add `CanvasViewModel` and inject the suggestion service.
17. Add `GhostSuggestionCard` with Accept and Dismiss actions.
18. Trigger mock suggestion from the AI button.
19. Optionally trigger mock suggestion from the bottom prompt.
20. Convert accepted suggestion items into visible floating glass cards on the canvas.
21. Add accessibility labels for all major controls.
22. Add English and Simplified Chinese localization strings.
23. Build and verify the iPad landscape layout.
24. Report:
   - implemented scope
   - files changed
   - run instructions
   - known limitations
   - next recommended task

## 7. Scope Guardrails

Do not include in the first implementation pass:

- real OCR
- real LLM integration
- collaboration
- account system
- paywall
- PDF reader
- template marketplace
- complex export
- production sync architecture

## 8. First-Pass Success Criteria

The first implementation pass is successful if:

1. The app clearly reads as an iPad-first AI ink canvas.
2. PencilKit drawing works.
3. Floating glass UI is visible and coherent.
4. A mock AI ghost suggestion appears.
5. Accepting the suggestion creates visible canvas cards.
6. English and Simplified Chinese are prepared.
7. Major controls have accessibility labels.
8. The demo feels calm, premium, and understandable.
