# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Pixel Office Companion** — an ambient developer companion that visualizes semantic coding activity as a cozy pixel-art office. It reflects state, not content. It is not a productivity tool.

## Components

Four independently-deployable components with no shared runtime dependencies:

| Component | Language | Purpose |
|---|---|---|
| `editor-extension/` | TypeScript | VS Code extension — observes editor events, emits over WebSocket |
| `protocol/` | JSON Schema | Versioned event contract (v1, frozen) |
| `tools/mock-event-server/` | TypeScript | Emits scripted protocol events for development |
| `companion-app/` | GDScript (Godot 4.x) | Consumes events, maintains state, renders pixel art |

## Build Commands

**Editor Extension:**
```bash
cd editor-extension
npm install
npm run compile        # one-shot build to ./out/
npm run vscode:prepublish  # production build
```

**Mock Event Server:**
```bash
cd tools/mock-event-server
npm install
npm run build          # compiles to ./dist/
npm run start          # starts server on ws://localhost:8787
```

**Companion App:** Open `companion-app/` in Godot 4.x. No CLI build.

There are no automated tests.

## Data Flow

Events flow strictly one direction: **Editor Extension → (WebSocket :8787) → Companion App**

```
Editor Events → Sensors → Normalizer → WebSocket Emitter → [ws://localhost:8787]
                                                                      ↓
                                              Validator → State Machine → Renderer
```

The mock event server replaces the editor extension during development by emitting the same protocol events on the same port.

## Protocol (Immutable)

Protocol v1 schema lives at `protocol/schema/event.v1.json`. **v1 is frozen — no new fields or event types.** All events share this envelope:

```json
{ "version": "1.0", "id": "<uuid>", "timestamp": "<ISO8601>", "type": "<type>", "payload": {} }
```

Seven event types: `activity.typing`, `activity.idle`, `ai.request.start`, `ai.request.stream`, `ai.request.end`, `outcome.test_pass`, `outcome.test_fail`. See `protocol/examples/` for payload shapes.

## Editor Extension Architecture

Three sensors feed a normalizer then a WebSocket emitter:

- `src/sensors/typingSensor.ts` — document changes → `activity.typing`; idles after 5s
- `src/sensors/aiSensor.ts` — VS Code Chat API hooks → `ai.request.*`
- `src/sensors/testSensor.ts` — task completion → `outcome.test_*`
- `src/eventNormalizer.ts` — adds `version`, `id` (UUID), `timestamp`
- `src/websocketEmitter.ts` — WebSocket client, retries every 5s, silent on send failure

## Companion App Architecture (Godot)

- `main.gd` — wires all nodes together
- `websocket_client.gd` — WebSocketPeer wrapper, auto-reconnects every 5s; signals: `connected`, `disconnected`, `message_received`
- `v1_validator.gd` — validates incoming events against protocol contract
- `state_machine.gd` — maps events to states with time-based decay; signals: `state_changed`
- `states.gd` — state constants: IDLE, TYPING, THINKING, SUCCESS, ERROR
- `renderer.gd` — sprite animation, nearest-neighbor pixel filtering; success/error don't loop

State decay timings: Typing 2s, Thinking 10s, Success 3s, Error 5s.

## Key Constraints

- The editor extension must never have UI, settings, analytics, or bidirectional communication.
- The companion app must never request data from the editor — all flow is push-only from extension to app.
- Protocol v1 is immutable; new versions require a new schema file and versioned handling in both extension and app.
- The extension connects to `ws://localhost:8787`; the mock server listens on the same address.
