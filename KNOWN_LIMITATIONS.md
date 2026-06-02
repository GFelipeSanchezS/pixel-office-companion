# Known Limitations and Future Work

This file tracks deliberate compromises made during development and features
deferred to a future implementation pass.

## Editor Extension

### Typing intensity is fixed at `"medium"`

**Current behavior:** Every `activity.typing` event is emitted with
`intensity: "medium"` regardless of actual typing speed.

**Why:** Protocol v1 requires the `intensity` field (`"low" | "medium" | "high"`),
but the current sensor has no mechanism to calculate it. Calculating intensity
requires tracking characters per second over a rolling time window and bucketing
the result.

**Future work:** Implement a rolling window counter in `typingSensor.ts` that
measures characters typed per second and maps to the three intensity levels.
Suggested thresholds: low < 2 chars/s, medium 2–8 chars/s, high > 8 chars/s.
Validate thresholds against real usage once art assets and animations exist.

---

### AI request outcome is fixed at `"success"`

**Current behavior:** Every `ai.request.end` event is emitted with
`outcome: "success"` regardless of whether the request actually succeeded or failed.

**Why:** The unofficial `vscode.chat` API used to observe AI request lifecycle
does not expose whether the response completed successfully or with an error.
There is no stable public VS Code API that provides this information.

**Future work:** Monitor the VS Code API for a stable, public request lifecycle
hook that exposes outcome. Until then, the companion will not distinguish between
a successful and a failed AI response.

---

### AI provider and kind are hardcoded

**Current behavior:** Every `ai.request.start` event is emitted with
`provider: "vscode"` and `kind: "chat"` regardless of the actual AI tool or
request type in use.

**Why:** The unofficial `vscode.chat` API does not expose provider identity or
request kind. There is no stable public VS Code API that provides this.

**Future work:** If a stable API becomes available that identifies the active AI
provider (GitHub Copilot, Cursor, etc.) and request kind (chat, inline, edit),
update `aiSensor.ts` to read and forward those values.

---

### AI sensor is unavailable outside VS Code

**Current behavior:** The AI sensor uses `vscode.chat`, an unofficial internal
API specific to VS Code. In other editors built on VS Code (Cursor, Windsurf,
etc.), this API may not exist. When absent, the sensor is silently skipped —
no `ai.request.*` events are emitted.

**Future work:** Investigate whether Cursor and other hosts expose equivalent
hooks under different namespaces, and add host-specific sensor variants if
justified by usage.

---

### Terminal sensor requires shell integration

**Current behavior:** `terminal.command.end` events are only emitted when VS Code
shell integration is active in the terminal. If the user's shell does not support
it or has it disabled, no terminal events are emitted.

**Why:** `window.onDidEndTerminalShellExecution` is the only stable public API for
observing individual command completions, and it depends on shell integration.

**Future work:** No alternative exists in the current VS Code API. Document shell
integration setup in the extension's settings description.

---

## Companion App

### Rush worker has no entry or exit movement

**Current behavior:** The rush worker appears instantly at the center desk when dispatched and disappears when their animation finishes. There is no walking animation through the doors.

**Why:** Entry and exit movement requires a Tween-based position animation that depends on the final background art layout — specifically the door positions. The positions in `office_scene.tscn` are placeholders.

**Future work:** Once the background art is in place and door positions are known, add a `Tween` to move the rush worker from off-screen (left door) to the center desk and back out (right door) around the action animation.

---

### Renderer does not yet have art assets

**Current behavior:** All 13 states and their 14 animation definitions (AWAY uses
two: `falling_asleep` and `sleeping`) are defined in `office_scene.tscn`, but all
animation frame arrays are empty. The renderer silently does nothing when a state
has no frames.

**Why:** Art assets are still in progress.

**Future work:** Add sprite frames to each animation in the Godot editor. States
that play once (SUCCESS, ERROR, TERMINAL, FILE\_SWITCH, FILE\_CREATE, FILE\_DELETE,
FILE\_RENAME) must have `loop = false` set on their animation in `SpriteFrames`.
