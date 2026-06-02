# Pixel Office Companion

A small, ambient developer companion that visualizes *semantic* coding activity
as a cozy pixel-art office.

This is **not** a productivity tool.
It reflects *state*, not content.

## Architecture

The system is split into independent layers with strict boundaries:

| Component | Language | Role |
|---|---|---|
| `editor-extension/` | TypeScript | Observes editor and AI events, emits over WebSocket |
| `protocol/` | JSON Schema | Versioned, immutable event contract |
| `tools/mock-event-server/` | TypeScript | Emits scripted protocol events for development |
| `companion-app/` | GDScript (Godot 4.x) | Validates events, drives state machine, renders visuals |

Data flows strictly one direction:

```
Editor Events → Sensors → Normalizer → WebSocket Emitter → [ws://localhost:8787]
                                                                      ↓
                                              Validator → State Machine → Renderer
```

The mock event server replaces the editor extension during development by emitting
the same protocol events on the same port.

Renderers are pure consumers. The editor extension never receives data.

## Key Constraints

- The editor extension must never have UI, settings, analytics, or bidirectional communication.
- The companion app must never request data from the editor — all flow is push-only.
- Protocol v1 is immutable; new versions require a new schema file and versioned handling in both the extension and the app.
- Both the extension and the mock server connect to / listen on `ws://localhost:8787`.

## Prerequisites

- **Node.js** v18 or later — for the editor extension and mock event server
- **Godot 4.x** — for the companion app; download the binary from [godotengine.org](https://godotengine.org/download)
- **VS Code** or **Cursor** — to use the editor extension

## Getting Started

**Option A — with real editor events:**

```bash
# Terminal 1: build the extension
cd editor-extension
npm install && npm run compile
```

Then in VS Code, open the `editor-extension/` folder and press **F5** to launch an Extension Development Host. Open the companion app in Godot 4.x and press **F5** to run the scene. Start coding.

**Option B — with mock events (no editor required):**

```bash
# Terminal 1: start the mock server
cd tools/mock-event-server
npm install && npm run build && npm start

# Terminal 2: open Godot and run the scene
```

Open `companion-app/` in Godot 4.x and press **F5**. Events from the mock server appear in the Godot Output panel.

## Build Commands

**Editor Extension:**
```bash
cd editor-extension
npm install
npm run compile          # builds to ./out/
```

**Mock Event Server:**
```bash
cd tools/mock-event-server
npm install
npm run build            # compiles to ./dist/
npm start                # listens on ws://localhost:8787
```

**Companion App:** Open `companion-app/` in Godot 4.x. No CLI build.

## Repository Structure

```
editor-extension/        VS Code extension (TypeScript)
  src/sensors/           Event sensors (typing, AI, test)
  src/normalizers/       Adds envelope fields (id, timestamp, version)
  src/emitter/           WebSocket client

protocol/                Event contract
  schema/event.v1.json   JSON Schema (frozen)
  examples/              One example file per event type

tools/mock-event-server/ Development event producer
  src/server.ts          WebSocket server on :8787
  src/timelines/         Scripted event sequences (JSON)

companion-app/           Godot 4.x application
  src/transport/         WebSocket client
  src/protocol/          Protocol v1 validator
  src/state/             State machine and state constants
  src/renderer/          Sprite animation renderer
```

## Status

MVP foundation complete. Visuals and animation in progress.
