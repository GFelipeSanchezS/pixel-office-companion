# Mock Event Server

## Purpose

Emits protocol v1 semantic events over WebSocket for development and testing.
Replaces the editor extension when you want to run the companion app without an
active editor session.

## Prerequisites

Node.js v18 or later.

## How to run

```bash
npm install
npm run build    # compiles TypeScript to ./dist/
npm start        # listens on ws://localhost:8787
```

## Development only

This server is intended for development and testing environments only.

## Timeline format

Events are scripted in `src/timelines/basic.json` as an ordered array of entries:

```json
[
  {
    "delay_ms": 500,
    "event": { ...protocol v1 event... }
  }
]
```

- `delay_ms` — how long to wait before emitting this entry, relative to the previous one
- `event` — a complete, valid protocol v1 event

The timeline loops continuously. Every event is validated against
`protocol/schema/event.v1.json` at startup; the server refuses to start if any
entry is invalid.

The default timeline (`basic.json`) covers all 18 protocol v1 event types in a
single loop, exercising every state in the companion app.

## Adding or modifying events

Edit `src/timelines/basic.json`, then rebuild:

```bash
npm run build
npm start
```

Events that fail schema validation at startup produce an error message that
identifies which entry is invalid and why.
