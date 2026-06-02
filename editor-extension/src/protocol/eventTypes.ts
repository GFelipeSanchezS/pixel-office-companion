export const EVENT_VERSION = "1.0" as const;

export type EventType =
  | "activity.typing"
  | "activity.idle"
  | "activity.focus"
  | "activity.away"
  | "ai.request.start"
  | "ai.request.stream"
  | "ai.request.end"
  | "debug.session.start"
  | "debug.session.end"
  | "debug.session.step"
  | "editor.file.switch"
  | "editor.file.create"
  | "editor.file.delete"
  | "editor.file.rename"
  | "outcome.test_pass"
  | "outcome.test_fail"
  | "task.process.start"
  | "terminal.command.end";

export type EventPayloads = {
  "activity.typing": { intensity: "low" | "medium" | "high" };
  "activity.idle": { duration_ms: number };
  "activity.focus": Record<string, never>;
  "activity.away": Record<string, never>;
  "ai.request.start": { provider: string; kind: string };
  "ai.request.stream": Record<string, never>;
  "ai.request.end": { outcome: "success" | "error" };
  "debug.session.start": { debuggerType: string };
  "debug.session.end": Record<string, never>;
  "debug.session.step": Record<string, never>;
  "editor.file.switch": { fileName: string };
  "editor.file.create": { files: string[] };
  "editor.file.delete": { files: string[] };
  "editor.file.rename": { oldName: string; newName: string };
  "outcome.test_pass": Record<string, never>;
  "outcome.test_fail": Record<string, never>;
  "task.process.start": { taskName: string };
  "terminal.command.end": { exitCode: number | null };
};

export type RawEvent<T extends EventType = EventType> = {
  type: T;
  payload: EventPayloads[T];
};

export type NormalizedEvent<T extends EventType = EventType> = {
  version: typeof EVENT_VERSION;
  id: string;
  timestamp: string;
  type: T;
  payload: EventPayloads[T];
};
