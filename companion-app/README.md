# Companion App

## Purpose

Connects to the local event stream, validates incoming protocol v1 events,
drives an internal state machine, and renders the companion character as a
pixel-art sprite.

## Constraints

- Never requests data from the editor — all flow is push-only from the extension to the app.
- No editor-specific assumptions in state or rendering logic.
- No protocol changes; consumes v1 as a pure consumer.

## How to run

1. Open `companion-app/` in Godot 4.x.
2. Run the scene (`main.gd` is the entry point).
3. The app connects to `ws://localhost:8787` automatically and reconnects every 5s on disconnect.

Start either the editor extension or the mock event server first so there is something to connect to.

## File structure

```
src/
  main.gd                  Entry point; wires client, validator, state machine, and renderer
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
