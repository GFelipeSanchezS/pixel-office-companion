# Pixel Office Companion

A small, ambient developer companion that visualizes *semantic* coding activity
as a cozy pixel-art office.

This is **not** a productivity tool.
It reflects *state*, not content.

## Architecture (by design)

The system is split into independent layers with strict boundaries:

- **Editor Extension**  
  Observes editor and AI lifecycle events and emits semantic events.

- **Protocol**  
  A versioned, JSON-based contract defining all events.

- **Mock Event Server**  
  Emits scripted protocol events for development and testing.

- **Companion App (Godot)**  
  Consumes events, maintains internal state, and renders visuals.

Data flow is strictly one-directional:

`Events → State → Rendering`

Renderers are pure consumers.

## Repository Structure

- `editor-extension/` — VS Code / Cursor extension
- `protocol/` — event schemas and examples
- `tools/mock-event-server/` — development event producer
- `companion-app/` — Godot-based companion application

## Status

MVP foundation complete.
Visuals and animation in progress.
