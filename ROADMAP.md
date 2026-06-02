# Roadmap

Tracks what is done and what comes next. Update this as work progresses.

---

## Done

- [x] Protocol v1 — 18 event types, JSON Schema, examples
- [x] Editor extension — 7 sensors, VS Code contribution settings, WebSocket emitter
- [x] Mock event server — timeline covering all 18 event types, schema validation at startup
- [x] Companion app — WebSocket client, protocol v1 validator, state machine (13 states)
- [x] Renderer — 5-worker dispatcher (4 desk + 1 rush), AWAY two-phase animation, idle fallback
- [x] Scene structure — 5 worker nodes, 14 animation definitions (empty frames), placeholder positions
- [x] Godot viewport — 480×270, canvas_items stretch, keep aspect ratio

---

## Up Next

### 1. Art — background
Create and import the office background (480×270 PNG).
See [ART_GUIDE.md](ART_GUIDE.md) for format and import steps.

### 2. Art — characters
Create and import all 5 worker sprite sheets with all 14 animations each.
Assign independent SpriteFrames to each worker node (Make Unique).
Adjust worker positions to align with the background.
See [ART_GUIDE.md](ART_GUIDE.md) for the full checklist.

### 3. Rush worker movement
Once door positions are known from the background art, add a Tween-based
entry/exit path to the rush worker so they walk in from a door and out the other.
See [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md) for details.

### 4. Ambient elements
Add the looping background life: cat walk, window clouds/street, computer screen glow.
See [ART_GUIDE.md](ART_GUIDE.md) — Ambient Elements section.

### 5. Editor extension — real-world test
Load the extension in VS Code via F5 (Extension Development Host) and verify
that real coding events (typing, AI requests, test runs, debug sessions, file ops)
reach the companion app and trigger the correct animations.

### 6. Windows test
Full stack test on Windows 11 after all changes since the last Windows run.
Steps: `npm install` + `npm run build` + `npm start` in mock server,
open companion app in Godot.

### 7. Typing intensity
Replace the fixed `"medium"` intensity with a real rolling-window calculation
in `typingSensor.ts`. See [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md).

### 8. Polish
- Tune animation FPS and decay timings against real usage
- Tune rush worker dispatch threshold (currently all 4 desk workers must be busy)
- Consider ambient sounds (optional)
- App window chrome — borderless, always-on-top, transparent background (makes
  it sit on the desktop like a true companion app)

---

## Known Limitations

See [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md) for a full list of deliberate
compromises and deferred work.
