# Companion App

## Purpose

Connects to the local event stream, validates incoming protocol v1 events,
drives an internal state machine, and renders the companion character as a
pixel-art sprite.

## Constraints

- Never requests data from the editor — all flow is push-only from the extension to the app.
- No editor-specific assumptions in state or rendering logic.
- Consumes protocol v1 as a pure consumer; no protocol changes belong here.

## Prerequisites

Godot 4.x — download the binary from [godotengine.org](https://godotengine.org/download).
No installer required; the binary runs as-is.

## How to run

1. Start the mock event server or the editor extension so there is something to connect to.
2. Open `companion-app/` in Godot 4.x.
3. Press **F5** to run the scene — `src/main.tscn` is the main scene.
4. The app connects to `ws://localhost:8787` automatically and reconnects every 5s on disconnect.
5. Incoming events and state transitions appear in the **Output** panel at the bottom of the editor.

## File structure

```
src/
  main.tscn                Main scene (Godot entry point)
  main.gd                  Root script; wires client, validator, state machine, and renderer
  transport/
    websocket_client.gd    WebSocketPeer wrapper; auto-reconnects every 5s
                           Signals: connected, disconnected, message_received
  protocol/
    v1_validator.gd        Validates event envelope and per-type payload against protocol v1
                           Returns { ok: bool, error: string }
  state/
    states.gd              State constants: IDLE, TYPING, THINKING, SUCCESS, ERROR,
                           AWAY, DEBUGGING, RUNNING, TERMINAL,
                           FILE_SWITCH, FILE_CREATE, FILE_DELETE, FILE_RENAME (13 total)
    state_machine.gd       Maps events to states; time-based decay back to IDLE
                           Signal: state_changed(new_state: String)
  renderer/
    renderer.gd            Worker dispatcher; manages 4 desk workers + 1 rush worker
    office_scene.tscn      Scene: Background, Worker1–4 at desks, RushWorker at center desk
```

## States and decay

| State | Trigger event(s) | Decays to IDLE after |
|---|---|---|
| `IDLE` | `activity.idle`, `activity.focus`, `debug.session.end`, or decay | — |
| `TYPING` | `activity.typing` | 2s |
| `THINKING` | `ai.request.start`, `ai.request.stream` | 10s |
| `SUCCESS` | `ai.request.end` (outcome: success), `outcome.test_pass` | 3s |
| `ERROR` | `ai.request.end` (outcome: error), `outcome.test_fail` | 5s |
| `AWAY` | `activity.away` | — (cleared only by `activity.focus`) |
| `DEBUGGING` | `debug.session.start`, `debug.session.step` | 30s |
| `RUNNING` | `task.process.start` | 60s |
| `TERMINAL` | `terminal.command.end` | 3s |
| `FILE_SWITCH` | `editor.file.switch` | 1s |
| `FILE_CREATE` | `editor.file.create` | 2s |
| `FILE_DELETE` | `editor.file.delete` | 2s |
| `FILE_RENAME` | `editor.file.rename` | 2s |

## Worker dispatcher

The renderer manages 5 workers — 4 at fixed desk positions and 1 rush worker at the center desk.

When a state change fires:
1. The first available desk worker is assigned the animation and marked busy
2. If all 4 desk workers are busy, the rush worker is used instead
3. When a worker's animation finishes, they return to idle and become available again

**AWAY** is handled differently — a worker plays `falling_asleep` once, then loops `sleeping` until `activity.focus` wakes them. No other events interrupt the sleeping worker.

The rush worker is invisible by default. It appears when dispatched and disappears when its animation finishes. Entry and exit movement (walking through the doors) will be added once art assets exist.

Worker positions in `office_scene.tscn` are placeholders and will be adjusted to align with the background art.

## State-to-animation mapping

Most states map to an animation of the same name lowercased (e.g. `TYPING` → `typing`).
`AWAY` is the exception — it uses two animations in sequence:

1. `falling_asleep` — plays once when `activity.away` is received
2. `sleeping` — loops continuously until `activity.focus` wakes the worker

All other states map one-to-one:

| Loop behaviour | States |
|---|---|
| Loops continuously | `IDLE`, `TYPING`, `THINKING`, `DEBUGGING`, `RUNNING`, `sleeping` |
| Plays once | `SUCCESS`, `ERROR`, `TERMINAL`, `FILE_SWITCH`, `FILE_CREATE`, `FILE_DELETE`, `FILE_RENAME`, `falling_asleep` |

There are 13 states but 14 animation definitions because `AWAY` requires two.

If an animation for a state does not exist in a worker's `SpriteFrames` resource,
the renderer silently does nothing — unknown or missing animations never crash the app.
