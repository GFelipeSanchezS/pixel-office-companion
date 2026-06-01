# Mock Event Server

## Purpose

Emits protocol v1 semantic events over WebSocket for development and testing.
Replaces the editor extension when you want to run the companion app without an
active editor session.

## How to run

```bash
npm install
npm run build
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

- `delay_ms` — how long to wait before emitting this entry (relative to the previous one)
- `event` — a complete, valid protocol v1 event

The timeline loops continuously. Every event is validated against `protocol/schema/event.v1.json`
at startup; the server refuses to start if any entry is invalid.

All emitted events are semantic and conform to protocol v1.
