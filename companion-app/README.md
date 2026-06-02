# Companion App

## Purpose

Connects to the local event stream, validates incoming protocol v1 events,
drives an internal state machine, and renders the companion character as a
pixel-art sprite.

## Constraints

- Never requests data from the editor — all flow is push-only from the extension to the app.
- No editor-specific assumptions in state or rendering logic.
- No protocol changes; consumes v1 as a pure consumer.

## Prerequisites

Godot 4.x — download the binary from [godotengine.org](https://godotengine.org/download). No installer required; the binary runs as-is.

## How to run

1. Start the mock event server or the editor extension so there is something to connect to.
2. Open `companion-app/` in Godot 4.x.
3. Press **F5** to run the scene — `src/main.tscn` is the main scene.
4. The app connects to `ws://localhost:8787` automatically and reconnects every 5s on disconnect.
5. Incoming events appear in the **Output** panel at the bottom of the editor.

## File structure

```
src/
  main.tscn                Main scene (Godot entry point)
  main.gd                  Root script; wires client, validator, state machine, and renderer
  transport/
    websocket_client.gd    WebSocketPeer wrapper; signals: connected, disconnected, message_received
  protocol/
    v1_validator.gd        Validates event envelope and per-type payload against protocol v1
  state/
    states.gd              State constants: IDLE, TYPING, THINKING, SUCCESS, ERROR
    state_machine.gd       Maps events to states; time-based decay back to IDLE
  renderer/
    renderer.gd            Drives AnimatedSprite2D; nearest-neighbor pixel filtering
    office_scene.tscn      Scene definition
```

## States and decay

| State | Trigger event(s) | Decays to IDLE after |
|---|---|---|
| `IDLE` | `activity.idle` or decay | — |
| `TYPING` | `activity.typing` | 2s |
| `THINKING` | `ai.request.start`, `ai.request.stream` | 10s |
| `SUCCESS` | `ai.request.end` (outcome: success), `outcome.test_pass` | 3s |
| `ERROR` | `ai.request.end` (outcome: error), `outcome.test_fail` | 5s |

`SUCCESS` and `ERROR` animations play once and do not loop.
All other animations loop continuously while the state is active.
