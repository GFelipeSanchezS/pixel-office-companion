# Protocol v1

Purpose

This protocol defines the stable, versioned event contract for the system.

Non-goals

- No editor implementation details
- No rendering or UI assumptions
- No analytics or storage guidance
- No transport guarantees beyond the event envelope

Versioning and compatibility

Each event includes a `version` field identifying the protocol version.

Protocol v1 is **frozen**:
- No new event types may be added to v1
- No payload fields may be added to v1
- Unknown event types or fields must be rejected by v1 consumers

Any extension or evolution requires a new protocol version (e.g. v2).
Backward compatibility is achieved through versioned schemas, not optional fields.

Semantic events only

Events describe semantic intent and outcomes, not mechanical or UI actions.

Renderers are consumers

Any rendering or visualization system is a consumer of this protocol only and
must not influence or alter event semantics.
