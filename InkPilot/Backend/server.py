"""
InkPilot local backend.

Proxies the iPad's `/suggest` request to MiniMax (OpenAI-compatible) and
returns a strict AISuggestionResponse JSON. The iOS app talks only to
this server; the MiniMax API key never leaves the Mac.

Run:
    cd Backend
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    cp .env.example .env  # then put your key in
    uvicorn server:app --host 0.0.0.0 --port 8000

The iPad connects over LAN to http://<Mac IP>:8000.
"""

from __future__ import annotations

import json
import logging
import os
import re
from typing import Literal

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

load_dotenv()

MINIMAX_API_KEY = os.getenv("MINIMAX_API_KEY", "")
MINIMAX_BASE_URL = os.getenv("MINIMAX_BASE_URL", "https://api.minimaxi.com/v1")
MINIMAX_MODEL = os.getenv("MINIMAX_MODEL", "MiniMax-M3")
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8000"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
log = logging.getLogger("inkpilot")

app = FastAPI(title="InkPilot Backend", version="0.2.0")

# CORS so the iPad (or a browser-based dev tool) can call us.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# MARK: - Schemas (mirror iOS AISuggestionResponse)

SuggestionMode = Literal["completion", "structure", "component", "diagram"]
CanvasObjectType = Literal[
    "aiCard",
    "textBox",
    "stickyNote",
    "bubble",
    "shape",
    "connector",
    "image",
    "file",
]


class SuggestionItem(BaseModel):
    id: str
    type: CanvasObjectType
    title: str
    content: str


class SuggestionResponse(BaseModel):
    mode: SuggestionMode
    title: str
    items: list[SuggestionItem]


class CanvasObjectContext(BaseModel):
    """Rich canvas context from the iPad app."""
    locale: str = Field(default="en", description="User locale (en, zh-Hans)")
    ink_text: str = Field(default="", description="Text extracted from ink strokes")
    prompt_text: str = Field(default="", description="User's typed prompt")
    selected_object: str | None = Field(default=None, description="Selected object summary")
    canvas_objects: list[dict] = Field(default_factory=list, description="Canvas object summaries")


class SuggestRequest(BaseModel):
    """What the iPad sends.

    Supports both legacy (context_text) and new (canvasContext) formats.
    The canvasContext is preferred when available.
    """

    # Legacy format (backward compatible)
    context_text: str = Field(default="", description="Raw text/note from the canvas")
    anchor_hint: str | None = Field(default=None, description="Optional anchor clue")
    mode_hint: SuggestionMode | None = Field(default=None, description="Optional mode hint")
    # Rich format (new)
    canvasContext: CanvasObjectContext | None = Field(default=None, description="Rich canvas context")


# MARK: - Routes


@app.get("/health")
async def health() -> dict:
    return {
        "ok": True,
        "model": MINIMAX_MODEL,
        "base_url": MINIMAX_BASE_URL,
        "api_key_set": bool(MINIMAX_API_KEY),
    }


@app.post("/suggest", response_model=SuggestionResponse)
async def suggest(req: SuggestRequest) -> SuggestionResponse:
    if not MINIMAX_API_KEY:
        raise HTTPException(status_code=503, detail="MINIMAX_API_KEY not configured on server")

    system_prompt = _system_prompt()
    user_prompt = _user_prompt(req)

    payload = {
        "model": MINIMAX_MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        "temperature": 0.4,
        "max_completion_tokens": 800,
        "thinking": {"type": "disabled"},
    }

    headers = {
        "Authorization": f"Bearer {MINIMAX_API_KEY}",
        "Content-Type": "application/json",
    }

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            r = await client.post(
                f"{MINIMAX_BASE_URL}/chat/completions",
                json=payload,
                headers=headers,
            )
    except httpx.HTTPError as e:
        log.error("MiniMax HTTP error: %s", e)
        raise HTTPException(status_code=502, detail=f"upstream error: {e}") from e

    if r.status_code != 200:
        log.error("MiniMax returned %s: %s", r.status_code, r.text[:400])
        raise HTTPException(status_code=502, detail=f"upstream {r.status_code}")

    body = r.json()

    # Check for app-level errors in 200 response
    base_resp = body.get("base_resp", {})
    if base_resp.get("status_code", 0) != 0:
        code = base_resp.get("status_code")
        msg = base_resp.get("status_msg", "unknown")
        log.error("MiniMax app error %s: %s", code, msg)
        raise HTTPException(status_code=502, detail=f"MiniMax error {code}: {msg}")

    raw = body["choices"][0]["message"]["content"]
    log.info("MiniMax raw: %s", raw[:200])

    parsed = _parse_strict(raw, fallback_mode=req.mode_hint or "structure")
    return parsed


# MARK: - Prompt & parsing


def _system_prompt() -> str:
    return (
        "You are InkPilot, an AI copilot for an iPad handwriting/whiteboard app. "
        "The user is writing freeform notes or sketching a product idea. "
        "You respond with ONE structured suggestion that helps the user move forward: "
        "a short title, and 2-4 concrete items that can be turned into canvas cards. "
        "Each item has a type that maps to a UI primitive: "
        "'aiCard' (a regular card with prose), 'textBox' (a label/heading), "
        "'stickyNote' (a short captured thought), 'bubble' (a callout), "
        "'shape' (a geometric figure), 'connector' (a line between two ideas). "
        "Keep titles under 8 words. Keep content under 24 words. "
        "The mode is one of: 'completion' (continue the thought), "
        "'structure' (organize the existing ideas), "
        "'component' (break down into concrete parts), "
        "'diagram' (visualize relationships). "
        "Reply with VALID JSON ONLY, exactly matching this schema: "
        '{"mode":"...","title":"...","items":[{"id":"...","type":"...","title":"...","content":"..."}]}'
    )


def _user_prompt(req: SuggestRequest) -> str:
    parts: list[str] = []

    # Use rich context if available
    if req.canvasContext:
        ctx = req.canvasContext
        if ctx.ink_text.strip():
            parts.append(f"Ink strokes:\n```\n{ctx.ink_text.strip()}\n```")
        if ctx.prompt_text.strip():
            parts.append(f"User prompt: \"{ctx.prompt_text.strip()}\"")
        if ctx.selected_object:
            parts.append(f"Selected object: {ctx.selected_object}")
        if ctx.canvas_objects:
            summaries = [f"- {o.get('type', '?')}: {o.get('title', '?')}" for o in ctx.canvas_objects[:8]]
            parts.append(f"Existing canvas objects:\n" + "\n".join(summaries))
        if ctx.locale.startswith("zh"):
            parts.append("Respond in Simplified Chinese.")
    else:
        # Legacy format
        if req.context_text.strip():
            parts.append(f"User's canvas content:\n```\n{req.context_text.strip()}\n```")

    if req.anchor_hint:
        parts.append(f"Anchor hint: {req.anchor_hint}")
    if req.mode_hint:
        parts.append(f"Preferred mode: {req.mode_hint}")
    if not parts:
        parts.append("The canvas is empty. Suggest a starting structure for a new product brainstorm.")
    return "\n\n".join(parts)


# Minimal fallback response so the iPad always gets a valid shape.
_FALLBACK_COUNTER = 0


def _parse_strict(raw: str, fallback_mode: SuggestionMode) -> SuggestionResponse:
    """Try to parse the LLM JSON. If it returns something loose, repair it.

    We use json.loads first; if that fails, we look for a JSON object in
    the response (common when models wrap JSON in ```json fences or
    add prose) and try to parse the first balanced object.
    """
    global _FALLBACK_COUNTER
    text = raw.strip()
    if text.startswith("```"):
        text = re.sub(r"^```(?:json)?\s*", "", text)
        text = re.sub(r"\s*```$", "", text)
    try:
        data = json.loads(text)
    except json.JSONDecodeError:
        match = re.search(r"\{.*\}", text, re.DOTALL)
        if not match:
            return _fallback(fallback_mode, reason="no json object in LLM output")
        try:
            data = json.loads(match.group(0))
        except json.JSONDecodeError:
            return _fallback(fallback_mode, reason="json parse failed after extraction")

    mode = data.get("mode") if data.get("mode") in {"completion", "structure", "component", "diagram"} else fallback_mode
    title = str(data.get("title", "Suggested next step"))[:80]
    items_raw = data.get("items", [])
    if not isinstance(items_raw, list) or not items_raw:
        return _fallback(fallback_mode, reason="no items")

    items: list[SuggestionItem] = []
    for i, it in enumerate(items_raw[:4]):
        if not isinstance(it, dict):
            continue
        item_id = str(it.get("id") or f"item-{i}-{_FALLBACK_COUNTER}")
        item_type = it.get("type") if it.get("type") in {
            "aiCard", "textBox", "stickyNote", "bubble", "shape", "connector", "image", "file"
        } else "aiCard"
        items.append(
            SuggestionItem(
                id=item_id,
                type=item_type,
                title=str(it.get("title", "Untitled"))[:80],
                content=str(it.get("content", ""))[:200],
            )
        )

    if not items:
        return _fallback(fallback_mode, reason="all items filtered out")

    _FALLBACK_COUNTER += 1
    return SuggestionResponse(mode=mode, title=title, items=items)


def _fallback(mode: SuggestionMode, reason: str) -> SuggestionResponse:
    global _FALLBACK_COUNTER
    _FALLBACK_COUNTER += 1
    log.warning("fallback response: %s", reason)
    return SuggestionResponse(
        mode=mode,
        title="Suggested next step",
        items=[
            SuggestionItem(
                id=f"fb-{_FALLBACK_COUNTER}-1",
                type="aiCard",
                title="Define the core question",
                content="What problem are you actually trying to solve?",
            ),
            SuggestionItem(
                id=f"fb-{_FALLBACK_COUNTER}-2",
                type="aiCard",
                title="List the top 3 users",
                content="Who would feel this pain most acutely in week one?",
            ),
            SuggestionItem(
                id=f"fb-{_FALLBACK_COUNTER}-3",
                type="aiCard",
                title="Sketch the smallest demo",
                content="What can you show in 60 seconds that proves the idea?",
            ),
        ],
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("server:app", host=HOST, port=PORT, reload=True)
