# Protocol v1

## Purpose

Defines the versioned event contract shared between the editor extension
and the companion app.

## Non-goals

- No editor implementation details
- No rendering or UI assumptions
- No analytics or storage guidance
- No transport guarantees beyond the event envelope

## Versioning

Protocol v1 is the current stable contract. Once shipped, v1 is frozen:

- No new event types may be added to v1
- No payload fields may be added to v1
- Unknown event types or fields must be rejected by v1 consumers

Any breaking change or extension requires a new schema file (e.g. `event.v2.json`)
and versioned handling in both the extension and the app.
Backward compatibility is achieved through versioned schemas, not optional fields.

## Event envelope

All events share this structure:

```json
{
  "version": "1.0",
  "id": "<uuid-v4>",
  "timestamp": "<ISO 8601>",
  "type": "<event-type>",
  "payload": {}
}
```

The full JSON Schema is at `schema/event.v1.json`.

## Event types and payloads

### Activity

| Type | Payload fields | Meaning |
|---|---|---|
| `activity.typing` | `intensity: "low" \| "medium" \| "high"` | User is typing in the editor |
| `activity.idle` | `duration_ms: number` | No typing for the configured idle period |
| `activity.focus` | *(empty)* | Editor window gained focus |
| `activity.away` | *(empty)* | Editor window lost focus |

### AI

| Type | Payload fields | Meaning |
|---|---|---|
| `ai.request.start` | `provider: string`, `kind: string` | AI chat request started |
| `ai.request.stream` | *(empty)* | AI response chunk received |
| `ai.request.end` | `outcome: "success" \| "error"` | AI chat request completed |

### Debug

| Type | Payload fields | Meaning |
|---|---|---|
| `debug.session.start` | `debuggerType: string` | Debug session started |
| `debug.session.step` | *(empty)* | Breakpoint hit or step executed |
| `debug.session.end` | *(empty)* | Debug session terminated |

### Editor

| Type | Payload fields | Meaning |
|---|---|---|
| `editor.file.switch` | `fileName: string` | Active editor file changed |
| `editor.file.create` | `files: string[]` | One or more files created |
| `editor.file.delete` | `files: string[]` | One or more files deleted |
| `editor.file.rename` | `oldName: string`, `newName: string` | A file was renamed |

### Outcome

| Type | Payload fields | Meaning |
|---|---|---|
| `outcome.test_pass` | *(empty)* | Test task exited with code 0 |
| `outcome.test_fail` | *(empty)* | Test task exited with non-zero code |

### Task

| Type | Payload fields | Meaning |
|---|---|---|
| `task.process.start` | `taskName: string` | A test task process started |

### Terminal

| Type | Payload fields | Meaning |
|---|---|---|
| `terminal.command.end` | `exitCode: number \| null` | Shell command completed (`null` if process was killed) |

## Semantic events only

Events describe semantic intent and outcomes, not mechanical or UI actions.
Renderers are consumers of this protocol only and must not influence event semantics.
