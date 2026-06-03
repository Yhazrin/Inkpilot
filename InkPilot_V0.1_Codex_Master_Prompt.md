# InkPilot V0.1 — iPadOS AI Ink Canvas Demo Master Prompt

> This document is intended to be given directly to Codex or another coding agent as the implementation specification for the first runnable InkPilot demo.

---

## 0. Executive Summary

You are building **InkPilot**, an iPadOS-first AI-native handwriting canvas demo.

InkPilot is not a normal notes app, not a chat app, not a document editor, and not a generic whiteboard. It is an **Apple Pencil-first infinite thinking space** where handwriting, sketches, AI predictions, and editable canvas components coexist in one spatial canvas.

The first version must feel like a polished product demo: simple, elegant, premium, calm, spatial, and Apple-like.

The goal of V0.1 is not to build a complete Goodnotes, Miro, Notion, or Freeform replacement.  
The goal is to prove one core interaction:

```text
User writes or sketches an idea on an infinite canvas
→ InkPilot shows a subtle AI ghost suggestion near the handwritten content
→ User taps Accept
→ The AI suggestion becomes editable floating glass components on the canvas
```

This should feel like **Cursor Tab completion for handwritten thinking**, expressed through an iPadOS infinite canvas.

---

## 1. Product Identity

### Product Name

**InkPilot**

### Product Category

Apple Pencil-first AI canvas.

### One-line English Positioning

> An Apple Pencil-first AI canvas that understands handwritten ideas, predicts the next move, and turns suggestions into editable canvas components.

### One-line Chinese Positioning

> 一个 Apple Pencil 优先的 AI 原生画布，能理解用户的手写想法，预测下一步，并生成可编辑的画布组件。

### Product Philosophy

```text
Handwriting is not just input.
Handwriting is the thinking process.

AI is not a separate chatbot.
AI is a canvas-native copilot.

The canvas is not a document.
The canvas is an infinite thinking space.
```

### Core Metaphor

> **Canvas is the world. Everything else floats.**

The center of the app should feel like an infinite spatial board. All tools, prompts, AI suggestions, panels, and generated objects should feel like floating glass components above the canvas.

---

## 2. V0.1 Product Scope

Build only the V0.1 demo foundation.

### V0.1 Must Include

1. A Freeform-style infinite canvas.
2. PencilKit drawing support for Apple Pencil / finger drawing.
3. A refined spatial background with large soft color blocks.
4. Floating Liquid Glass-style interface components.
5. A top floating tool capsule.
6. A bottom floating prompt capsule.
7. A compact floating AI Pilot panel.
8. A mock AI ghost suggestion card.
9. Tap-to-accept interaction for the AI ghost suggestion.
10. Accepted suggestions become real glass canvas cards.
11. Basic canvas object model.
12. Clean architecture for future OCR and LLM integration.
13. Basic English / Simplified Chinese localization.
14. Basic accessibility labels for major controls.
15. A beautiful runnable iPadOS demo.

### V0.1 Should Not Include

Do not implement these unless they already exist cleanly and require minimal effort:

1. Real OCR.
2. Real LLM API integration.
3. Real-time multiplayer collaboration.
4. Full note library.
5. PDF reader.
6. Account system.
7. Subscription / paywall.
8. Template marketplace.
9. Complex diagram editor.
10. CRDT syncing.
11. Full offline AI.
12. Complex file export.
13. App Store production hardening.

V0.1 should be a polished interaction prototype, not a complete productivity platform.

---

## 3. First Demo Scenario

Use this fixed demo scenario.

### Scenario

The user is brainstorming a new AI handwriting product.

The user writes or the app simulates the context:

```text
AI handwriting notes
```

A ghost suggestion appears near the handwriting:

```text
Suggested structure:
- Target users
- Core workflow
- MVP features
```

The user taps **Accept**.

The suggestion turns into three real floating glass cards on the canvas:

```text
Target Users
Core Workflow
MVP Features
```

Optional second step:

User taps the AI button or lasso placeholder. A mock diagram suggestion appears:

```text
Ink Input
→ Recognition
→ Context Engine
→ Suggestion Layer
→ Canvas Components
```

The diagram can be rendered as a single elegant glass card in V0.1. It does not need to be a full diagram engine.

---

## 4. Visual Design Direction

The interface should feel like:

```text
Apple Freeform-like infinite canvas
+ iPadOS Liquid Glass floating chrome
+ large soft color blocks
+ subtle AI ghost overlays
+ minimal Apple Pencil-first interaction
```

### Style Keywords

- Simple
- Elegant
- Premium
- Spatial
- Calm
- Lightweight
- Apple-like
- Editorial
- Refined
- Minimal chrome
- Floating glass
- Large soft color blocks
- No visual noise

### Avoid

- Cyberpunk neon
- Heavy gradients
- Harsh shadows
- Cluttered dashboard UI
- Traditional document pages
- A4 paper metaphor
- Fixed heavy sidebars
- ChatGPT-style dominant chat panel
- Overly saturated colors
- Low-quality glassmorphism
- Excessive animations

### Design Tone

The app should feel like a calm premium iPadOS creative tool.  
It should not feel like a SaaS dashboard, a note-taking clone, or a messy whiteboard.

---

## 5. Visual System

### 5.1 Background

The canvas background should feel infinite and spatial.

Use:

- Off-white / warm light gray base.
- Large soft color blocks.
- Subtle spatial grid or dot texture.
- Very low-contrast background geometry.
- Smooth premium color balance.

Avoid:

- Paper texture.
- Obvious page boundaries.
- Strong grid lines.
- Cheap rainbow gradients.

Suggested color direction:

```text
Base: warm off-white / soft mist gray
Accent 1: soft blue-violet
Accent 2: mint green
Accent 3: warm peach / soft amber
Ink: near-black with slight warmth
AI: pale blue / violet glow
```

### 5.2 Floating Glass

All interface chrome should look floating and glass-like.

Reusable components should include:

```text
GlassCard
GlassCapsule
FloatingPanel
AIBadge
ColorBlockBackground
```

Glass style:

- Rounded corners.
- Translucent material.
- Subtle blur.
- Soft border highlight.
- Very light shadow.
- No harsh outline.
- No heavy opacity.
- No cheap frosted glass effect.

If latest iPadOS Liquid Glass APIs are available, use them carefully.  
If not, use SwiftUI materials such as `.ultraThinMaterial`, `.regularMaterial`, opacity, overlay stroke, and soft shadow.

### 5.3 AI Visual Identity

AI-generated or AI-suggested content must look different from user handwriting.

| Content Type | Visual Treatment |
|---|---|
| User handwriting | Dark, direct, physical ink |
| AI ghost suggestion | Semi-transparent, faint border, light text, subtle sparkle |
| Accepted AI component | More solid glass card, small AI badge |
| Floating UI chrome | Glass capsule / panel |
| Canvas background | Calm, spacious, low contrast |

Important:

AI should feel present but not loud.  
The ghost suggestion should feel like a possible next thought, not a blocking modal.

---

## 6. Main Canvas Layout

The canvas screen should conceptually look like this:

```text
┌──────────────────────────────────────────────┐
│                                              │
│           [Floating Tool Capsule]            │
│                                              │
│                                              │
│           Infinite Freeform Canvas            │
│                                              │
│     handwriting       AI ghost card           │
│                                              │
│        accepted glass component cards         │
│                                              │
│                              [AI Pilot]       │
│                                              │
│          [Bottom Prompt Capsule]              │
│                                              │
└──────────────────────────────────────────────┘
```

Important layout principles:

1. The canvas is the main surface.
2. No fixed hard sidebar.
3. No full-width top navigation bar.
4. No large permanent chat panel.
5. Floating components should not visually trap the canvas.
6. AI suggestions should appear near content, not only in a side panel.
7. The app should work well in iPad landscape orientation.

---

## 7. Layer Architecture

Use a clear conceptual layer model.

```text
InkPilotCanvasRoot
├── SpatialBackgroundLayer
│   ├── subtle grid or dots
│   ├── soft color blocks
│   └── zoom-aware light texture
│
├── InfiniteCanvasLayer
│   ├── PencilKit ink strokes
│   ├── user-created objects
│   ├── AI-generated cards
│   ├── mind nodes
│   └── diagram objects
│
├── AIInteractionLayer
│   ├── ghost suggestions
│   ├── scanning highlights
│   ├── lasso selection preview
│   └── generation previews
│
└── FloatingChromeLayer
    ├── top tool capsule
    ├── bottom prompt capsule
    ├── AI Pilot floating panel
    ├── collaborator badges
    └── contextual menus
```

V0.1 does not need every future feature, but the code should be organized in a way that supports this direction.

---

## 8. Core Screens

### 8.1 Home Screen

Create a simple premium home screen.

Content:

```text
InkPilot

Think with your pencil.
Let AI pilot the next move.

[New AI Canvas]
```

Optional mock recent canvas cards:

```text
Product Brainstorm
Class Notes
Research Map
```

Visual requirements:

- Large color-block background.
- One hero glass card.
- Minimal copy.
- Generous spacing.
- Elegant typography.
- No clutter.
- The main call-to-action should be clear.

### 8.2 Canvas Screen

The canvas screen is the core product.

Required visible elements:

1. Infinite spatial background.
2. PencilKit drawing surface.
3. Top floating tool capsule.
4. Bottom prompt capsule.
5. AI Pilot floating panel.
6. AI ghost suggestion card.
7. Accepted glass component cards.

The screen should instantly communicate:

```text
This is an infinite Apple Pencil canvas.
The UI floats as glass components.
AI appears as a ghost suggestion.
Accepted AI suggestions become canvas components.
```

---

## 9. Floating UI Components

### 9.1 Top Floating Tool Capsule

Position: top center or top leading.

Tools:

```text
Pen | Eraser | Lasso | Text | AI | Share
```

V0.1 required:

- Pen
- Eraser
- Lasso placeholder
- AI trigger button

Design:

- Glass capsule.
- SF Symbols icons.
- Selected tool shown with soft filled pill.
- Compact, elegant, not full-width.
- Should float above the canvas.

Behavior:

- Pen enables drawing.
- Eraser switches PencilKit to eraser if feasible.
- Lasso can be placeholder.
- AI button triggers mock ghost suggestion.
- Share can be placeholder or hidden in V0.1.

### 9.2 Bottom Prompt Capsule

Position: bottom center.

Placeholder text:

```text
Ask AI about this canvas...
```

V0.1 behavior:

- Can trigger mock suggestion when tapped or submitted.
- Does not need real LLM.
- Should remain lightweight.
- Should not dominate the canvas.

### 9.3 AI Pilot Floating Panel

Position: right bottom or right middle.

Collapsed state:

```text
AI Pilot
3 suggestions
```

Expanded mock content:

```text
Canvas Context
Product brainstorming

Suggestions
- Define MVP scope
- Make user flow
- Compare competitors
```

Behavior:

- Can be static in V0.1.
- Can expand/collapse if simple.
- Should feel like a small copilot panel, not a chat sidebar.

### 9.4 AI Ghost Suggestion Card

This is the most important component.

Prediction state:

- Appears near the recent handwriting or canvas center.
- Semi-transparent glass.
- Faint border.
- Optional dashed or soft glowing outline.
- Small AI badge or sparkle icon.
- Shows title and 2-4 suggestion items.
- Includes Accept and Dismiss actions.

Example content:

```text
Suggested structure
Target users
Core workflow
MVP features
```

Accepted state animation:

- Subtle glow sweep.
- Opacity increases.
- Ghost card turns into solid glass cards.
- Items become real canvas objects.

### 9.5 Accepted Canvas Cards

Accepted AI suggestions become real objects on the canvas.

Design:

- Rounded glass cards.
- Clean title.
- Short body text if needed.
- Small AI badge.
- Draggable if feasible.
- World-positioned canvas objects.

Example accepted cards:

```text
Target Users
Core Workflow
MVP Features
```

---

## 10. Interaction Design

### Required V0.1 Interactions

1. User can draw on the canvas using PencilKit.
2. User can switch between pen and eraser if feasible.
3. User can trigger a mock AI suggestion from the AI button.
4. User can trigger a mock AI suggestion from the bottom prompt if simple.
5. AI ghost suggestion appears.
6. User can tap Accept.
7. Suggestion turns into glass canvas cards.
8. User can dismiss the suggestion.
9. Accepted cards can be displayed as canvas objects.
10. Accepted cards can be dragged if feasible.

### Optional V0.1 Interactions

1. Pinch zoom.
2. Two-finger pan.
3. Lasso selection preview.
4. Floating radial AI menu.
5. Card dragging.
6. Canvas object selection.
7. Simple diagram mock card.
8. Small scanning animation before suggestion appears.

Do not block the V0.1 demo on complex gesture perfection.

---

## 11. Infinite Canvas and Coordinate System

Because InkPilot is an infinite canvas, avoid hard-coding everything in screen coordinates.

Introduce a canvas transform model:

```swift
struct CanvasTransform {
    var scale: CGFloat
    var offset: CGSize
}
```

Canvas objects should conceptually live in world coordinates:

```swift
struct CanvasObject {
    var worldPosition: CGPoint
    var size: CGSize
}
```

Rendering converts world coordinates to screen coordinates.

V0.1 can use a simplified implementation, but the architecture should not make future infinite canvas support difficult.

---

## 12. Canvas Object Model

Create a clean canvas object model.

Suggested Swift types:

```swift
enum CanvasObjectType: String, Codable {
    case ink
    case textCard
    case checklist
    case mindNode
    case diagram
    case ghostSuggestion
}

enum CreatorType: String, Codable {
    case user
    case ai
    case collaborator
}

struct CanvasObject: Identifiable, Codable {
    let id: UUID
    var type: CanvasObjectType
    var worldPosition: CGPointCodable
    var size: CGSizeCodable
    var content: CanvasContent
    var style: CanvasObjectStyle
    var createdBy: CreatorType
    var sourceInkIds: [UUID]
    var confidence: Double?
}
```

Suggested content model:

```swift
enum CanvasContent: Codable {
    case plainText(String)
    case checklist([ChecklistItem])
    case mindNode(title: String, children: [String])
    case diagram(nodes: [DiagramNode], edges: [DiagramEdge])
}
```

Add lightweight placeholder models if needed:

```swift
struct ChecklistItem: Codable, Identifiable {
    var id: UUID
    var text: String
    var isDone: Bool
}

struct DiagramNode: Codable, Identifiable {
    var id: UUID
    var title: String
    var position: CGPointCodable
}

struct DiagramEdge: Codable, Identifiable {
    var id: UUID
    var from: UUID
    var to: UUID
}
```

If `CGPoint` or `CGSize` Codable support is inconvenient, create wrappers:

```swift
struct CGPointCodable: Codable {
    var x: CGFloat
    var y: CGFloat
}

struct CGSizeCodable: Codable {
    var width: CGFloat
    var height: CGFloat
}
```

---

## 13. AI Suggestion Schema

Even though V0.1 uses mock AI, define a future-ready schema.

```swift
struct AISuggestionResponse: Codable {
    var mode: SuggestionMode
    var title: String
    var items: [AISuggestionItem]
}

enum SuggestionMode: String, Codable {
    case completion
    case structure
    case component
    case diagram
}

struct AISuggestionItem: Codable, Identifiable {
    var id: UUID
    var type: CanvasObjectType
    var title: String
    var content: String
}
```

Future AI output should map to this shape:

```json
{
  "mode": "structure",
  "title": "Suggested structure",
  "items": [
    {
      "type": "textCard",
      "title": "Target Users",
      "content": "Students, product managers, researchers"
    },
    {
      "type": "textCard",
      "title": "Core Workflow",
      "content": "Write → Recognize → Predict → Accept"
    },
    {
      "type": "textCard",
      "title": "MVP Features",
      "content": "PencilKit canvas, OCR, ghost suggestion, tap to accept"
    }
  ]
}
```

The AI should generate **canvas components**, not long chat answers.

---

## 14. AI Service Architecture

Use a protocol-first design.

```swift
protocol SuggestionService {
    func generateSuggestion(context: CanvasContext) async throws -> AISuggestionResponse
}
```

For V0.1:

```swift
final class MockSuggestionService: SuggestionService {
    func generateSuggestion(context: CanvasContext) async throws -> AISuggestionResponse {
        // Return fixed mock suggestions
    }
}
```

Future services can include:

```text
VisionOCRService
FoundationModelSuggestionService
CloudLLMSuggestionService
CanvasContextBuilder
```

Do not implement real OCR or real LLM in V0.1.  
Only create clean placeholders if helpful.

### Mock AI Replacement Rule

Mock AI must be implemented behind the `SuggestionService` protocol.

Views should not directly construct hard-coded AI responses.  
`CanvasViewModel` should call `SuggestionService`.  
In V0.1, inject `MockSuggestionService`.

Later, this can be replaced by:

```text
Vision OCR
→ CanvasContextBuilder
→ Foundation Models or Cloud LLM
→ Structured AISuggestionResponse
```

---

## 15. Recognition Architecture Placeholder

V0.1 does not need real OCR, but reserve clean file boundaries.

Future flow:

```text
Recent ink region
→ Render local snapshot
→ Vision OCR
→ Build canvas context
→ Generate structured AI suggestion
→ Show ghost suggestion
```

Suggested placeholder files:

```text
InkSnapshotRenderer.swift
VisionOCRService.swift
CanvasContextBuilder.swift
```

They can be stubbed in V0.1.

---

## 16. Technical Stack

Use:

- SwiftUI for UI.
- PencilKit for drawing.
- Future Vision OCR support.
- MockSuggestionService for V0.1.
- Codable models for canvas state.
- Clean design system components.
- Basic localization using `Localizable.xcstrings` or `Localizable.strings`.

Avoid:

- Unnecessary external dependencies.
- Massive single-file implementation.
- Hard-coded scattered styling.
- Complex architecture that blocks a runnable demo.
- Real backend dependency in V0.1.

---

## 17. Suggested File Structure

Create or adapt this structure:

```text
InkPilot/
├── App/
│   └── InkPilotApp.swift
│
├── DesignSystem/
│   ├── BrandTokens.swift
│   ├── ColorBlockBackground.swift
│   ├── GlassCard.swift
│   ├── GlassCapsule.swift
│   ├── FloatingToolbar.swift
│   ├── FloatingPromptCapsule.swift
│   ├── AIBadge.swift
│   └── MotionTokens.swift
│
├── Canvas/
│   ├── InkCanvasView.swift
│   ├── PencilKitCanvasRepresentable.swift
│   ├── CanvasTransform.swift
│   ├── CanvasObject.swift
│   ├── CanvasObjectLayer.swift
│   ├── AIOverlayLayer.swift
│   ├── FloatingChromeLayer.swift
│   └── GhostSuggestionCard.swift
│
├── AI/
│   ├── SuggestionSchema.swift
│   ├── SuggestionService.swift
│   ├── MockSuggestionService.swift
│   └── CanvasContextBuilder.swift
│
├── Recognition/
│   ├── InkSnapshotRenderer.swift
│   └── VisionOCRService.swift
│
├── Localization/
│   ├── Localizable.xcstrings
│   └── README.md
│
└── Screens/
    ├── HomeView.swift
    └── CanvasView.swift
```

If the existing project has a different structure, adapt carefully without breaking the project.

---

## 18. ShipSwift Reference

If the ShipSwift repository or components are available, inspect it as inspiration for SwiftUI components and animations.

Potentially useful components or ideas:

```text
Shimmer
GlowSweep
LightSweep
ScanningOverlay
AnimatedMeshGradient
ColorPanels
ThinkingIndicator
MarkdownText
SearchBar
Floating components
```

Do not blindly import the entire ShipSwift project.

Only borrow, recreate, or adapt small pieces that fit InkPilot’s own identity.

InkPilot’s design identity is:

```text
Elegant infinite canvas
+ floating glass chrome
+ AI ghost suggestion
+ Apple Pencil-first interaction
```

ShipSwift should be treated as a component and animation reference, not as the product foundation.

---

## 19. Animation and Motion

Use subtle motion.

Good motion examples:

- Ghost card fades in near handwriting.
- Accept action triggers a soft glow sweep.
- Cards gently settle into the canvas.
- Floating panels have soft spring transitions.
- AI Pilot panel expands calmly.
- Background color blocks move very subtly if implemented.

Avoid:

- Fast bouncy animations.
- Excessive particle effects.
- Loud AI glow.
- Distracting motion.
- Game-like transitions.

Animation should feel premium and calm.

---

## 20. Localization, Accessibility, and Friendly UX Guidelines

InkPilot V0.1 should feel friendly, international-ready, and accessible from the beginning.

Even though V0.1 is a demo, do not hard-code the product into a single-language, single-device, single-user-experience prototype.

---

### 20.1 Chinese and English Adaptation

InkPilot should support both **English** and **Simplified Chinese** UI copy.

Required languages for V0.1:

```text
English
Simplified Chinese
```

Do not hard-code visible UI strings directly inside SwiftUI views.

Use a localization-friendly approach, preferably:

```text
Localizable.xcstrings
or Localizable.strings
```

All visible interface text should be prepared for localization, including:

```text
InkPilot
Think with your pencil.
Let AI pilot the next move.
New AI Canvas
Ask AI about this canvas...
AI Pilot
Suggested structure
Target users
Core workflow
MVP features
Accept
Dismiss
Pen
Eraser
Lasso
Text
Share
Canvas Context
Suggestions
```

Suggested English copy:

```text
InkPilot
Think with your pencil.
Let AI pilot the next move.
New AI Canvas
Ask AI about this canvas...
AI Pilot
Suggested structure
Target users
Core workflow
MVP features
Accept
Dismiss
```

Suggested Chinese copy:

```text
InkPilot
用笔思考，让 AI 续航灵感。
新建 AI 画布
询问当前画布...
AI 副驾驶
建议结构
目标用户
核心流程
MVP 功能
接受
忽略
```

Important:

- Do not translate the product name `InkPilot`.
- Chinese UI should not be a stiff literal translation.
- English UI should be concise and product-like.
- Chinese UI should be natural, elegant, and not too verbose.
- Avoid mixing Chinese and English randomly unless it is intentional branding.
- Keep UI labels short enough to fit floating glass components.

---

### 20.2 Language Behavior

V0.1 should follow the system language by default.

Preferred behavior:

```text
If system language is Chinese → show Simplified Chinese UI.
If system language is not Chinese → show English UI.
```

Do not build a complex in-app language switcher in V0.1 unless it is very simple and does not slow down the demo.

However, keep the code structure ready for future manual language switching.

---

### 20.3 Typography for Bilingual UI

The typography should look good in both English and Chinese.

Guidelines:

1. Use system fonts by default.
2. Avoid custom font dependencies in V0.1.
3. Ensure Chinese text does not feel cramped.
4. Avoid overly small text in floating cards.
5. Use generous line spacing for Chinese paragraphs.
6. Keep titles short and readable.
7. Avoid all-caps styling for long English text.
8. Make sure button labels still fit in Chinese.

Suggested text hierarchy:

```text
Large title: app name / screen title
Medium title: card title / AI suggestion title
Body: card content
Caption: badges / metadata / helper text
```

Chinese text often needs slightly more breathing room.  
Floating cards should be flexible enough to handle longer localized strings.

---

### 20.4 Accessibility Basics

InkPilot should follow basic iPadOS accessibility expectations.

V0.1 should support:

1. Dynamic Type where feasible.
2. VoiceOver labels for important buttons.
3. Sufficient contrast for text and controls.
4. Comfortable tap targets.
5. Reduced motion friendliness.
6. Clear focus states where relevant.
7. Safe area handling.
8. Landscape iPad usability.

Minimum tap target guidance:

```text
Interactive controls should generally be at least 44x44 points.
```

Important controls that need accessibility labels:

```text
New AI Canvas
Pen
Eraser
Lasso
AI
Share
Accept suggestion
Dismiss suggestion
Open AI Pilot panel
Bottom AI prompt
```

Example accessibility intent:

```text
The AI ghost card should be understandable by VoiceOver as:
"AI suggestion. Suggested structure. Target users, Core workflow, MVP features. Accept or dismiss."
```

Do not let the glass style reduce readability.  
Visual elegance must not harm clarity.

---

### 20.5 Reduced Motion and Calm Animation

Animations should be subtle and premium.

If the user enables Reduce Motion, avoid large animated movement.

Motion guidelines:

1. Use soft fade and scale transitions.
2. Avoid excessive bouncing.
3. Avoid rapid flashing.
4. Avoid strong particle effects.
5. Avoid constant background animation.
6. Keep AI glow subtle.
7. Use animation to clarify state changes, not to decorate randomly.

Accepting a ghost suggestion can use:

```text
soft fade
subtle glow sweep
gentle card settle
```

But it should never feel noisy or game-like.

---

### 20.6 Friendly First-Run Experience

The app should be understandable without explanation.

On the first canvas, include a minimal empty-state hint.

Example English:

```text
Start writing anywhere.
InkPilot will suggest the next step.
```

Example Chinese:

```text
在任意位置开始书写。
InkPilot 会预测你的下一步想法。
```

The hint should disappear or become less prominent after the user starts drawing.

Do not use a long tutorial in V0.1.  
The product should teach itself through the interface.

---

### 20.7 Friendly Empty, Loading, and Error States

Even in V0.1, avoid dead or confusing states.

Prepare basic states:

#### Empty canvas

```text
Start writing anywhere.
```

```text
在任意位置开始书写。
```

#### AI thinking / mock generating

```text
Reading the canvas...
```

```text
正在理解画布...
```

#### No suggestion available

```text
No suggestion yet. Try writing a little more.
```

```text
暂时没有建议。可以再多写一点。
```

#### Mock mode indicator, if needed

```text
Demo suggestion
```

```text
演示建议
```

Do not show technical errors to the user in the main UI.  
For V0.1, use friendly fallback copy.

---

### 20.8 Input Friendliness

InkPilot should feel good with:

```text
Apple Pencil
Finger touch
Keyboard
Trackpad, if used on iPad with Magic Keyboard
```

V0.1 should prioritize Apple Pencil, but should not become unusable without it.

Guidelines:

1. Apple Pencil draws naturally.
2. Finger can tap UI and drag objects.
3. Keyboard can type into the bottom prompt if implemented.
4. Escape or outside tap can dismiss floating panels if feasible.
5. Accept/Dismiss actions should be easy to tap.

Do not make the user rely on hidden gestures only.  
Every important action should have a visible path.

---

### 20.9 Undo, Clear, and Forgiveness

Creative tools need forgiveness.

V0.1 should include at least one simple recovery mechanism if feasible:

```text
Undo drawing
Clear canvas
Dismiss suggestion
Remove accepted card
```

If full undo is too much, implement at least:

```text
Dismiss ghost suggestion
Clear canvas
```

The user should never feel trapped after accepting or dismissing a suggestion.

---

### 20.10 Privacy-Friendly Product Tone

InkPilot is built around personal handwriting and thinking.

Even if V0.1 uses mock AI, the product tone should feel privacy-aware.

Do not imply that handwriting is uploaded unless real upload exists.

Future-facing privacy copy can be prepared but not overemphasized.

Example:

```text
Your canvas stays private in this demo.
```

```text
当前演示中，你的画布内容仅保留在本地。
```

Avoid scary or overly technical privacy language.

---

### 20.11 Orientation and Layout Friendliness

V0.1 should prioritize iPad landscape layout.

However, avoid breaking completely in portrait.

Guidelines:

1. Landscape should look best.
2. Floating controls should respect safe areas.
3. Bottom prompt should not collide with the home indicator.
4. AI Pilot panel should not cover the main handwriting area too aggressively.
5. Cards should remain readable after rotation if rotation is supported.
6. Use adaptive layout where simple.

---

### 20.12 Copywriting Tone

InkPilot copy should be:

```text
clear
calm
short
premium
not childish
not overly technical
not SaaS-like
```

Avoid phrases like:

```text
Supercharge your workflow!!!
AI-powered productivity revolution
10x your notes
```

Prefer:

```text
Think with your pencil.
Let AI pilot the next move.
Start writing anywhere.
Suggested structure.
Accept suggestion.
```

Chinese copy should be restrained and elegant.

Avoid overly internet-style Chinese such as:

```text
一键起飞
超强 AI 加持
效率爆炸
```

Prefer:

```text
用笔思考，让 AI 续航灵感。
在任意位置开始书写。
建议结构。
接受建议。
```

---

### 20.13 Implementation Requirements for Localization

When implementing V0.1:

1. Create localization files for English and Simplified Chinese.
2. Avoid hard-coded visible strings in SwiftUI views.
3. Use localized keys consistently.
4. Keep the localization key names readable.
5. Ensure glass components can handle both English and Chinese strings.
6. Do not build a complex language settings screen unless trivial.
7. Make previews or mock states easy to inspect in both languages if feasible.

Example localization key style:

```text
home.title
home.subtitle
home.newCanvas
canvas.prompt.placeholder
canvas.aiPilot.title
suggestion.title.structure
suggestion.accept
suggestion.dismiss
tool.pen
tool.eraser
tool.lasso
tool.ai
```

---

### 20.14 Updated V0.1 Friendly Design Success Criteria

InkPilot V0.1 is successful only if:

1. The UI works in both English and Simplified Chinese.
2. No major visible string is hard-coded.
3. Floating glass components remain readable in both languages.
4. Important controls have accessibility labels.
5. The canvas is usable with Apple Pencil and touch.
6. The interface remains calm and understandable.
7. Empty, loading, and dismiss states feel friendly.
8. The app feels premium without sacrificing clarity.

---

## 21. Platform and Device Constraints

Target **iPadOS first**.

The primary layout should be optimized for iPad landscape.  
The app may run on iPhone, but iPhone layout is not the priority for V0.1.

Use adaptive SwiftUI layout where simple, but do not over-optimize for every screen size.

Respect:

- Safe areas.
- Apple Pencil interaction.
- Magic Keyboard / trackpad usage when available.
- Landscape-first spatial layout.
- Portrait fallback if simple.

Do not make the app look like a phone-first productivity app.

---

## 22. PencilKit and Gesture Priority

Infinite canvas + PencilKit can create gesture conflicts. Handle this deliberately.

Interaction priority:

1. Apple Pencil input should primarily draw on the PencilKit layer.
2. Finger touch should primarily interact with floating UI and canvas objects.
3. Two-finger gestures can be used for pan / zoom if implemented.
4. Dragging accepted cards should not accidentally draw ink.
5. If gesture conflicts become complex, prioritize PencilKit drawing and simple card interactions over full infinite canvas gestures in V0.1.

Do not wrap PencilKit in a gesture system that breaks normal drawing.

A stable Apple Pencil drawing experience is more important than advanced infinite canvas gestures in the first pass.

---

## 23. State Management Principles

Use a simple state container for V0.1.

Prefer a lightweight `ObservableObject` or `@Observable` view model, such as:

```text
CanvasViewModel
HomeViewModel, if needed
```

`CanvasViewModel` should own:

- Canvas objects.
- Current tool.
- Ghost suggestion state.
- AI panel state.
- Selected object.
- Mock suggestion service.
- Basic canvas transform if implemented.

Do not scatter important state across many unrelated SwiftUI views.

Do not introduce complex global architecture unless the existing project already uses one.

---

## 24. Progressive Enhancement and Fallback Strategy

Use progressive enhancement.

If latest Liquid Glass APIs are unavailable, fall back to SwiftUI Material-based glass.

If advanced canvas zoom is unstable, keep a simple static large canvas.

If eraser mode is difficult, provide a clear placeholder and keep pen drawing working.

If card dragging causes gesture conflicts, make accepted cards static in V0.1.

If localization tooling is difficult, at minimum centralize all copy in a localization-ready helper or string file, but prefer real localization files.

A stable, elegant, runnable demo is more important than incomplete advanced features.

---

## 25. Engineering Integration Strategy

Before implementing, inspect the existing repository carefully.

Do not assume the project is empty.

Do not replace the app entry point blindly.

Do not delete existing files unless necessary.

If the project already has an app structure, integrate InkPilot as a new feature module.

If the project is empty or minimal, create a clean InkPilot app structure.

Before coding:

1. Inspect the existing project structure.
2. Identify whether it is SwiftUI, UIKit, or mixed.
3. Identify the app entry point.
4. Identify current deployment target.
5. Summarize how InkPilot V0.1 will be integrated.
6. Do not delete existing important files unless necessary.

---

## 26. Implementation Order

Implement in this order.

### Phase 1 — Project Inspection and Plan

Before coding:

1. Inspect the existing project structure.
2. Identify whether it is SwiftUI, UIKit, or mixed.
3. Identify the app entry point.
4. Identify current deployment target.
5. Summarize how you will integrate InkPilot V0.1.
6. Do not delete existing important files unless necessary.

### Phase 2 — UI Skeleton

Build:

1. HomeView.
2. CanvasView.
3. ColorBlockBackground.
4. GlassCard.
5. GlassCapsule.
6. Top floating tool capsule.
7. Bottom prompt capsule.
8. AI Pilot floating panel.
9. Empty infinite canvas surface.

Goal: the app should already look like InkPilot before AI or PencilKit is complete.

### Phase 3 — PencilKit Layer

Build:

1. PencilKitCanvasRepresentable.
2. Drawing layer inside the canvas.
3. Pen mode.
4. Eraser mode if feasible.
5. Keep drawing responsive.

### Phase 4 — Mock AI Ghost Suggestion

Build:

1. SuggestionSchema.
2. SuggestionService protocol.
3. MockSuggestionService.
4. GhostSuggestionCard.
5. AI button triggers mock suggestion.
6. Bottom prompt can trigger mock suggestion if simple.
7. Accept and Dismiss actions.

### Phase 5 — Accepted Canvas Components

Build:

1. CanvasObject model.
2. CanvasObjectLayer.
3. Convert accepted suggestion items into CanvasObject instances.
4. Render them as floating glass cards.
5. Add simple dragging if feasible.

### Phase 6 — Localization and Accessibility Pass

Build or verify:

1. English localization.
2. Simplified Chinese localization.
3. Localized UI strings for all visible text.
4. Accessibility labels for major controls.
5. Readable layout in both languages.
6. Friendly empty/loading/dismiss states.

### Phase 7 — Polish

Polish:

1. Spacing.
2. Typography.
3. Glass materials.
4. Shadows.
5. Animations.
6. iPad landscape layout.
7. Home-to-canvas transition.
8. Empty state.
9. Build warnings.

---

## 27. First Implementation Task

For the first coding pass, implement only:

```text
Phase 1
+ Phase 2
+ Phase 3
+ Phase 4
+ basic English / Simplified Chinese localization
+ basic accessibility labels for major controls
```

That means:

1. Inspect the project.
2. Create the InkPilot home screen.
3. Create the canvas screen.
4. Add PencilKit drawing.
5. Add floating glass UI.
6. Add mock AI ghost suggestion.
7. Add Accept / Dismiss for ghost suggestion.
8. Prepare localized UI strings for English and Simplified Chinese.
9. Add accessibility labels to the main controls.

Do not implement real OCR, real LLM, real collaboration, account, paywall, PDF, or template system.

After this first pass, provide:

1. What was implemented.
2. Files changed.
3. How to run.
4. Known limitations.
5. Next recommended task.

---

## 28. Important Execution Constraints

Do not turn this into a generic notes app.

Do not turn this into a chat app.

Do not build account, paywall, PDF, collaboration, OCR, or real LLM in the first pass.

Do not overengineer.

The first pass must produce a beautiful and runnable iPadOS demo with:

- Home screen.
- Infinite-canvas-like screen.
- PencilKit drawing.
- Floating glass UI.
- Mock AI ghost suggestion.
- Accept / Dismiss.
- Accepted glass cards.
- Basic English / Simplified Chinese localization.
- Basic accessibility labels.

Keep the demo coherent, elegant, and minimal.

---

## 29. Quality Bar

The result is acceptable only if:

1. The app feels like an iPad-first product, not a web dashboard.
2. The canvas feels infinite, not like a document page.
3. Floating UI feels elegant and glass-like.
4. AI suggestion appears as a subtle ghost card.
5. Accepting the ghost card creates visible canvas components.
6. PencilKit drawing works.
7. The code is modular and understandable.
8. The build remains runnable.
9. The V0.1 scope is not polluted by unrelated features.
10. The UI supports English and Simplified Chinese.
11. Major controls have accessibility labels.
12. The interaction feels calm, premium, and understandable.

---

## 30. Verification Checklist

After implementation, verify:

1. The app builds successfully.
2. Home screen opens.
3. New AI Canvas enters the canvas screen.
4. PencilKit drawing works.
5. Floating toolbar is visible.
6. Bottom prompt is visible.
7. AI Pilot panel is visible.
8. AI button triggers ghost suggestion.
9. Accept turns suggestion into glass cards.
10. Dismiss removes ghost suggestion.
11. English and Simplified Chinese localized strings exist.
12. Major controls have accessibility labels.
13. The layout works in iPad landscape.
14. The glass components remain readable.
15. The demo does not include real OCR/LLM/paywall/account/collaboration.

If the project has test or build commands, run them and report the result.

If unable to run because of environment limitations, clearly state that.

---

## 31. Final Success Criteria

InkPilot V0.1 is successful if a viewer can understand the concept within 10 seconds:

```text
This is an infinite Apple Pencil canvas.
The UI floats as elegant glass components.
AI suggestions appear as ghost cards.
Accepted AI suggestions become real canvas components.
InkPilot is not a chat app.
InkPilot is an AI-native thinking space.
```

Do not expand beyond this target until the V0.1 interaction feels visually polished, coherent, and runnable.
