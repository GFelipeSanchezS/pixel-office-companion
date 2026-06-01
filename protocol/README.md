# Protocol v1

## Purpose

Defines the stable, versioned event contract shared between the editor extension
and the companion app.

## Non-goals

- No editor implementation details
- No rendering or UI assumptions
- No analytics or storage guidance
- No transport guarantees beyond the event envelope

## Versioning

Protocol v1 is **frozen**:

- No new event types may be added to v1
- No payload fields may be added to v1
- Unknown event types or fields must be rejected by v1 consumers

Any extension or evolution requires a new schema file (e.g. `event.v2.json`)
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

The JSON Schema is at `schema/event.v1.json`.

## Event types and payloads

| Type | Payload fields |
|---|---|
| `activity.typing` | `intensity: "low" \| "medium" \| "high"` |
| `activity.idle` | `duration_ms: number` |
| `ai.request.start` | `provider: string`, `kind: string` |
| `ai.request.stream` | *(empty)* |
| `ai.request.end` | `outcome: "success" \| "error"` |
| `outcome.test_pass` | *(empty)* |
| `outcome.test_fail` | *(empty)* |

See `examples/` for a concrete JSON file per event type.

## Semantic events only

Events describe semantic intent and outcomes, not mechanical or UI actions.
Renderers are consumers of this protocol only and must not influence event semantics.
