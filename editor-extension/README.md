# Editor Extension

## Purpose

Observes editor and AI lifecycle signals, normalizes them into semantic protocol
events, and emits those events over a local WebSocket connection.

## Constraints

- No custom UI — no webviews, panels, or status bar items.
- No analytics or data storage.
- No inbound or bidirectional communication — the extension only pushes events, never receives them.

## Event flow

```
sensors → normalizer → emitter → ws://localhost:8787
```

## File structure

```
src/
  extension.ts               Entry point; wires sensors, normalizer, and emitter
  sensors/
    typingSensor.ts          document changes → activity.typing; idle after 5s
    aiSensor.ts              VS Code Chat API hooks → ai.request.*
    testSensor.ts            task completions → outcome.test_*
  normalizers/
    eventNormalizer.ts       adds version, id (UUID v4), timestamp (ISO 8601)
  emitter/
    websocketEmitter.ts      WebSocket client; retries every 5s; drops silently on send failure
  protocol/
    eventTypes.ts            TypeScript types for raw and normalized events
```

## Signals observed

### Currently implemented

| VS Code API | Stability | Protocol event | Visual meaning | Key payload |
|---|---|---|---|---|
| `workspace.onDidChangeTextDocument` | Stable | `activity.typing` | Character is writing | `intensity: "low"\|"medium"\|"high"` |
| *(idle timer — 5s after last change)* | — | `activity.idle` | Character stops and sits still | `duration_ms: number` |
| `vscode.chat.onDidStartChatRequest` | **Unofficial** | `ai.request.start` | Character leans back and thinks | `provider: string, kind: string` |
| `vscode.chat.onDidReceiveChatResponse` | **Unofficial** | `ai.request.stream` | Character is still thinking, response arriving | *(empty)* |
| `vscode.chat.onDidEndChatRequest` | **Unofficial** | `ai.request.end` | Character reacts to AI result | `outcome: "success"\|"error"` |
| `tasks.onDidEndTaskProcess` | Stable | `outcome.test_pass` / `outcome.test_fail` | Character celebrates or slumps | *(empty)* |

The unofficial `vscode.chat` hooks are guarded — if the API does not exist in the host, those sensors are silently skipped and no `ai.request.*` events are emitted.

### Planned (protocol v2)

| VS Code API | Stability | Proposed event | Visual meaning | Key payload |
|---|---|---|---|---|
| `window.onDidChangeWindowState` | Stable | `activity.away` / `activity.focus` | Character looks around or falls asleep when window loses focus | `focused: boolean` |
| `debug.onDidStartDebugSession` | Stable | `activity.debug_start` | Character puts on a magnifying glass, enters detective mode | `type: string` (debugger type) |
| `debug.onDidTerminateDebugSession` | Stable | `activity.debug_end` | Character puts magnifying glass away | *(empty)* |
| `debug.onDidChangeActiveStackItem` | Stable | `activity.debug_step` | Character actively inspects something — breakpoint hit or stepping | *(empty)* |
| `tasks.onDidStartTaskProcess` | Stable | `activity.task_start` | Character starts running something — pairs with existing test end | `taskName: string` |
| `window.onDidEndTerminalShellExecution` | Stable | `activity.terminal` | Character uses a laptop within the scene | `exitCode: number\|undefined` |
| `workspace.onDidChangeActiveTextEditor` | Stable | `activity.file_switch` | Character swaps notebooks — one per open file | `fileName: string` |
| `workspace.onDidCreateFiles` | Stable | `activity.file_create` | Character pulls a new notebook from a drawer | `files: string[]` |
| `workspace.onDidDeleteFiles` | Stable | `activity.file_delete` | Character throws a notebook in the bin | `files: string[]` |
| `workspace.onDidRenameFiles` | Stable | `activity.file_rename` | Character writes a new label on the notebook cover | `oldName: string, newName: string` |

`window.onDidEndTerminalShellExecution` requires shell integration to be active in the terminal.

## Prerequisites

- Node.js v18 or later
- VS Code v1.80 or later (or Cursor)

## Build and run

```bash
npm install
npm run compile        # one-shot build to ./out/
```

To run the extension during development, open the `editor-extension/` folder in VS Code and press **F5**. This launches an Extension Development Host — a second VS Code window with the extension loaded. Any file edits in that window emit events to `ws://localhost:8787`.

```bash
npm run vscode:prepublish  # production build before packaging
```
