# Known Limitations and Future Work

This file tracks deliberate compromises made during development and features
deferred to a future protocol version or implementation pass.

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
These thresholds should be validated against real usage once art assets exist.

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
API that is specific to VS Code. In other editors built on VS Code (Cursor,
Windsurf, etc.), this API may not exist. When it is absent, the sensor is
silently skipped — no `ai.request.*` events are emitted.

**Future work:** Investigate whether Cursor and other hosts expose equivalent
hooks under different namespaces, and add host-specific sensor variants if
justified by usage.

---

## Protocol

### v1 has no debug or focus events

The current protocol has no event types for debug session state
(`outcome.debug_start`, `outcome.debug_end`) or window focus
(`activity.focus`, `activity.away`). These were considered but deferred
to avoid expanding v1 scope before the companion had visuals.

**Future work:** Define these in protocol v2 once the companion has art and
the value of each signal can be evaluated against a real animation set.
