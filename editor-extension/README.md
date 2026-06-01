# Editor Extension

## Purpose

Observes editor and AI lifecycle signals, normalizes them into semantic protocol
events, and emits those events over a local WebSocket connection.

## Constraints

- No UI, settings, or configuration surface of any kind.
- No analytics or data storage.
- No inbound or bidirectional communication — the extension only pushes events, never receives them.

## Event flow

```
sensors → normalizer → emitter → ws://localhost:8787
```

## File structure

```
src/
  extension.ts               Entry point; wires sensors, normalizer, and emitter
  sensors/
    typingSensor.ts          document changes → activity.typing; idle after 5s
    aiSensor.ts              VS Code Chat API hooks → ai.request.*
    testSensor.ts            task completions → outcome.test_*
  normalizers/
    eventNormalizer.ts       adds version, id (UUID v4), timestamp (ISO 8601)
  emitter/
    websocketEmitter.ts      WebSocket client; retries every 5s; drops silently on send failure
  protocol/
    eventTypes.ts            TypeScript types for raw and normalized events
```

## Event types emitted

| Type | Trigger |
|---|---|
| `activity.typing` | Any document change |
| `activity.idle` | No document change for 5 seconds |
| `ai.request.start` | AI chat request begins |
| `ai.request.stream` | AI response chunk received |
| `ai.request.end` | AI chat request completes |
| `outcome.test_pass` | Test task exits with code 0 |
| `outcome.test_fail` | Test task exits with non-zero code |

## Build

```bash
npm install
npm run compile        # one-shot build to ./out/
npm run vscode:prepublish  # production build
```
