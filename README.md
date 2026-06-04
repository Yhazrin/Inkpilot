# InkPilot

An Apple Pencil-first AI canvas for iPadOS. Write, sketch, and think with your pencil — AI suggests the next move.

## What It Is

InkPilot is an infinite canvas app where handwriting, AI suggestions, and structured canvas objects coexist. AI ghost suggestions appear near your ink, and accepted suggestions become editable canvas components.

## Architecture

```
InkPilot/
├── App/              — Entry point
├── Screens/          — HomeView, CanvasView, palettes, overlays
├── DesignSystem/     — Glass components, brand tokens, motion tokens
├── Canvas/           — CanvasObject model, transform, PencilKit, factory
├── AI/               — SuggestionService protocol, mock + network, context builder
├── Recognition/      — OCR stubs (future)
└── Resources/        — Localizations (en, zh-Hans), Info.plist, Assets
```

### Key Abstractions

- **CanvasTransform** — zoom/pan state, world↔screen coordinate conversion
- **CanvasObject** — typed content (aiCard, text, sticky, shape, connector, media) with position, size, rotation, zIndex
- **SuggestionService** — protocol for AI suggestions; MockSuggestionService for offline, NetworkSuggestionService for backend
- **CanvasContextBuilder** — builds rich context (strokes, objects, selection, prompt) for AI
- **MotionTokens** — semantic animation presets (emerge, materialize, settle)

## Running

1. Open `InkPilot/InkPilot.xcodeproj` in Xcode 15.4+
2. Select iPad simulator (iPadOS 17.0+)
3. Build & Run (⌘R)

### AI Backend (Optional)

The app works offline with mock suggestions. For real AI:

1. `cd InkPilot/Backend && pip install -r requirements.txt`
2. Set `OPENAI_API_KEY` in `.env`
3. `uvicorn server:app --host 0.0.0.0 --port 8000`
4. Update `BackendConfig.baseURL` in the iOS project to your Mac's LAN IP

## Current Status

- ✅ PencilKit drawing with stroke smoothing
- ✅ Infinite canvas with CanvasTransform (zoom/pan sync)
- ✅ Canvas objects: aiCard, text, sticky, bubble, shape, connector, media
- ✅ AI ghost suggestion with anchor-based emerge animation
- ✅ Accept → canvas cards with materialization animation
- ✅ Object select, drag, delete, duplicate
- ✅ Shape and media palettes
- ✅ English + Simplified Chinese localization
- ✅ Accessibility labels on all controls
- ✅ Offline mock AI + optional network backend

## Design Spec

See `InkPilot_V0.1_Codex_Master_Prompt.md` for the full product specification.
