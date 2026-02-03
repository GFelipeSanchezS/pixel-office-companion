# Editor Event Sensor

Purpose

This extension observes editor and AI lifecycle signals, normalizes them into
semantic events, and emits those events over a local WebSocket connection.

Non-goals

- No UI or visual output
- No configuration or settings UI
- No analytics or storage
- No inbound or bidirectional communication

Event flow (unidirectional)

  sensors -> normalizers -> emitter -> ws://localhost:8787

Event types

- activity.typing
- activity.idle
- ai.request.start
- ai.request.stream
- ai.request.end
- outcome.test_pass
- outcome.test_fail
