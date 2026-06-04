# InkPilot Backend

A small FastAPI server that proxies the iPad's `/suggest` request to
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

The server logs the LAN IP it bound to. Test it:

```bash
curl http://localhost:8000/health
# {"ok":true,"model":"MiniMax-Text-01","api_key_set":true}

curl -X POST http://localhost:8000/suggest \
  -H "Content-Type: application/json" \
  -d '{"context_text":"Build a product that helps students take notes with Apple Pencil"}'
```

## iPad configuration

The iOS app needs to know the Mac's LAN address. Open
`InkPilot/AI/NetworkSuggestionService.swift` and set:

```swift
static let baseURL = URL(string: "http://192.168.1.x:8000")!
```

Replace `192.168.1.x` with the IP printed when the server starts.
The app's `Info.plist` already includes `NSAllowsLocalNetworking = true`
so HTTP to a private-range IP is allowed.

## Endpoints

| Method | Path        | Body                | Response                |
|--------|-------------|---------------------|-------------------------|
| GET    | `/health`   | —                   | `{ok, model, api_key_set}` |
| POST   | `/suggest`  | `SuggestRequest`    | `SuggestionResponse`    |

`SuggestRequest`:

```json
{
  "context_text": "user's notes from the canvas",
  "anchor_hint": "optional",
  "mode_hint": "completion|structure|component|diagram"
}
```

`SuggestionResponse`:

```json
{
  "mode": "structure",
  "title": "Suggested structure",
  "items": [
    {"id": "...", "type": "aiCard", "title": "...", "content": "..."}
  ]
}
```

## Switching providers

`MINIMAX_BASE_URL`, `MINIMAX_MODEL`, and the auth header in
`server.py` are the only places that hard-code MiniMax. Replace those
three lines to talk to OpenAI / Anthropic / Ollama / whatever.

## Security

- `.env` is gitignored. **Do not commit it.**
- The server binds to `0.0.0.0` so the iPad can reach it, but you may
  want to restrict to your subnet's bridge interface in production.
- No authentication. This is a development server on a trusted LAN.
