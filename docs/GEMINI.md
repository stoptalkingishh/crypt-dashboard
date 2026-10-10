# Gemini (bring-your-own key)

The `✦` "Ask Gemini" panel calls Google's Generative Language API **directly from
the browser** with an API key you paste into Settings/Admin. There is no proxy and
no server; the key lives in `localStorage` (`cryptdash:ai:v1`) and is sent only
to `generativelanguage.googleapis.com`.

## Setup

1. Get a key from Google AI Studio (<https://aistudio.google.com/apikey>).
2. Settings/Admin → **gemini key**, optionally set **gemini model**.
3. Press `✦` and ask. The News module (planned) reuses this panel for story
   briefings via `openAiPrefill()`.

## Request shape

```
POST https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent
Header: x-goog-api-key: <key>
Body:   { systemInstruction, contents:[{role:"user",parts:[{text}]}] }
```

## Model fallback

Google retires models on its own schedule, so the app walks a list rather than
hardcoding one name (adapted from `openquiz`). A `404` / "not found" on the
preferred model retries the next candidate; other errors surface to the user.

```js
const GEMINI_MODELS = [
  "gemini-3.5-flash",
  "gemini-3.5-flash-lite",
  "gemini-3.1-flash-lite",
  "gemini-2.5-flash",
];
```

## What it is used for today

- Free-form Q&A / text summarisation in the launcher panel.

## Notes

- No key → the panel shows "no key set" and the Ask button explains how to add one.
- The key is per-browser; it is never written to Drive or committed.
- A future server-side proxy was considered and rejected to keep the app
  client-only (see [ROADMAP.md](ROADMAP.md)).
