# InkPilot Backend

A FastAPI server that proxies the iPad's AI suggestion request to
**MiniMax** (OpenAI-compatible) and returns a strict `AISuggestionResponse`
JSON. The iOS app talks to **this** server — the MiniMax API key never
leaves the Mac.

## Why a backend

The iPad can't safely hold an LLM API key. By putting the key behind a
local FastAPI server, we get:

- The key stays in `.env` on the developer's Mac
- The iPad only sees a plain HTTP endpoint on the LAN
- Swapping MiniMax for another provider later is a one-file change

## Setup

```bash
cd Backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

cp .env.example .env
# Edit .env and put your MINIMAX_API_KEY in
```

## Run

```bash
uvicorn server:app --host 0.0.0.0 --port 8000 --reload
```

## Test (no API key — uses mock fallback)

```bash
curl -X POST http://localhost:8000/api/inkpilot/suggestions \
  -H "Content-Type: application/json" \
  -d '{"canvasContext":{"locale":"zh-Hans","inkText":"AI 手写笔记","promptText":"帮我整理"}}'
```

## Test (with MiniMax key)

Same curl command, but with `MINIMAX_API_KEY` set in `.env`.

## Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/health` | Server status |
| POST | `/api/inkpilot/suggestions` | **Formal endpoint** — AI suggestions |
| POST | `/suggest` | Local shortcut (same handler) |

### Request (rich format)

```json
{
  "canvasContext": {
    "locale": "zh-Hans",
    "inkText": "User has drawn 3 stroke(s); Ink bounds: 200x150",
    "promptText": "帮我整理一下",
    "selectedObject": null,
    "canvasObjects": [
      {"type": "aiCard", "title": "目标用户"}
    ]
  }
}
```

### Request (legacy format — still supported)

```json
{
  "context_text": "user's notes from the canvas",
  "anchor_hint": "optional",
  "mode_hint": "structure"
}
```

### Response (always `AISuggestionResponse`)

```json
{
  "mode": "structure",
  "title": "建议结构",
  "items": [
    {"id": "...", "type": "aiCard", "title": "目标用户", "content": "..."},
    {"id": "...", "type": "aiCard", "title": "核心流程", "content": "..."}
  ]
}
```

## MiniMax API reference

- **Base URL:** `https://api.minimaxi.com/v1` (official per OpenAPI spec)
- **Model:** `MiniMax-M3` (current flagship)
- **Auth:** `Authorization: Bearer <API_KEY>`
- **Endpoint:** `/chat/completions` (OpenAI-compatible)
- **Token param:** `max_completion_tokens` (not deprecated `max_tokens`)
- **Thinking:** `{"type": "disabled"}` for simple canvas tasks
- **Structured output:** Not supported via `response_format`; prompt-based JSON only
- **Docs:** https://platform.minimaxi.com/docs

## iPad configuration

Set `INKPILOT_BACKEND_URL` in Info.plist to your Mac's LAN IP,
or update `BackendConfig.swift` default.

## Security

- `.env` is gitignored. **Do not commit it.**
- No MiniMax API key in the iPad app.
- Server binds to `0.0.0.0` for LAN access.
- No authentication. Development server on trusted LAN only.
