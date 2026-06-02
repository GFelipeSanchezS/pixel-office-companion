# Editor Extension

## Purpose

Observes editor and AI lifecycle signals, normalizes them into semantic protocol
events, and emits those events over a local WebSocket connection.

## Constraints

- No custom UI — no webviews, panels, or status bar items.
- No analytics or data storage.
- No inbound or bidirectional communication — the extension only pushes events, never receives them.
- Sensors are individually togglable via VS Code settings; disabled sensors register no event listeners.

## Event flow

```
sensors → normalizer → emitter → ws://localhost:8787
```

## File structure

```
src/
  extension.ts               Entry point; reads settings, wires enabled sensors and emitter
  sensors/
    typingSensor.ts          document changes → activity.typing; idle timer → activity.idle
    aiSensor.ts              vscode.chat hooks → ai.request.* (unofficial API, guarded)
    testSensor.ts            task process start/end → task.process.start, outcome.test_*
    debugSensor.ts           debug session lifecycle → debug.session.*
    windowSensor.ts          window focus/blur → activity.away/focus; file switch → editor.file.switch
    fileSensor.ts            file create/delete/rename → editor.file.*
    terminalSensor.ts        shell execution end → terminal.command.end
  normalizers/
    eventNormalizer.ts       adds version, id (UUID v4), timestamp (ISO 8601)
  emitter/
    websocketEmitter.ts      WebSocket client; retries every 5s; drops silently on send failure
  protocol/
    eventTypes.ts            TypeScript types for raw and normalized events
```

## Settings

All sensors are enabled by default. Each can be disabled independently in VS Code
via **File → Preferences → Settings → Pixel Office Companion**.

| Setting | Default | Sensors controlled |
|---|---|---|
| `pixelOfficeCompanion.sensors.typing` | `true` | Typing and idle |
| `pixelOfficeCompanion.sensors.ai` | `true` | AI chat request lifecycle |
| `pixelOfficeCompanion.sensors.tests` | `true` | Test task start and outcome |
| `pixelOfficeCompanion.sensors.debug` | `true` | Debug session lifecycle |
| `pixelOfficeCompanion.sensors.window` | `true` | Window focus/blur and active file change |
| `pixelOfficeCompanion.sensors.files` | `true` | File create, delete, and rename |
| `pixelOfficeCompanion.sensors.terminal` | `true` | Terminal shell command completion |

Disabling a sensor prevents its event listeners from being registered entirely —
there is no polling or filtering at runtime.

## Signals observed

| VS Code API | Stability | Protocol event | Visual meaning | Key payload |
|---|---|---|---|---|
| `workspace.onDidChangeTextDocument` | Stable | `activity.typing` | Character is writing | `intensity: "low"\|"medium"\|"high"` |
| *(idle timer — 5s after last change)* | — | `activity.idle` | Character stops and sits still | `duration_ms: number` |
| `window.onDidChangeWindowState` | Stable | `activity.away` / `activity.focus` | Character falls asleep or wakes up | *(empty)* |
| `vscode.chat.onDidStartChatRequest` | **Unofficial** | `ai.request.start` | Character leans back and thinks | `provider: string, kind: string` |
| `vscode.chat.onDidReceiveChatResponse` | **Unofficial** | `ai.request.stream` | Character still thinking, response arriving | *(empty)* |
| `vscode.chat.onDidEndChatRequest` | **Unofficial** | `ai.request.end` | Character reacts to AI result | `outcome: "success"\|"error"` |
| `debug.onDidStartDebugSession` | Stable | `debug.session.start` | Character puts on magnifying glass | `debuggerType: string` |
| `debug.onDidChangeActiveStackItem` | Stable | `debug.session.step` | Character actively inspects, breakpoint hit | *(empty)* |
| `debug.onDidTerminateDebugSession` | Stable | `debug.session.end` | Character puts magnifying glass away | *(empty)* |
| `window.onDidChangeActiveTextEditor` | Stable | `editor.file.switch` | Character swaps notebooks | `fileName: string` |
| `workspace.onDidCreateFiles` | Stable | `editor.file.create` | Character pulls a new notebook from a drawer | `files: string[]` |
| `workspace.onDidDeleteFiles` | Stable | `editor.file.delete` | Character throws a notebook in the bin | `files: string[]` |
| `workspace.onDidRenameFiles` | Stable | `editor.file.rename` | Character writes a new label on the cover | `oldName: string, newName: string` |
| `tasks.onDidStartTaskProcess` | Stable | `task.process.start` | Character starts running something | `taskName: string` |
| `tasks.onDidEndTaskProcess` | Stable | `outcome.test_pass` / `outcome.test_fail` | Character celebrates or slumps | *(empty)* |
| `window.onDidEndTerminalShellExecution` | Stable | `terminal.command.end` | Character uses a laptop in the scene | `exitCode: number\|null` |

The unofficial `vscode.chat` hooks are guarded — if the API does not exist in the
host (Cursor, Windsurf, etc.), the AI sensor is silently skipped and no
`ai.request.*` events are emitted.

`window.onDidEndTerminalShellExecution` requires shell integration to be active
in the terminal. If shell integration is off, no `terminal.command.end` events are emitted.

## Prerequisites

- Node.js v18 or later
- VS Code v1.80 or later (or Cursor)

## Build and run

```bash
npm install
npm run compile        # one-shot build to ./out/
```

To run the extension during development, open the `editor-extension/` folder in
VS Code and press **F5**. This launches an Extension Development Host — a second
VS Code window with the extension active. Any file edits, debug sessions, test runs,
or AI chat requests in that window emit events to `ws://localhost:8787`.

```bash
npm run vscode:prepublish  # production build before packaging
```
