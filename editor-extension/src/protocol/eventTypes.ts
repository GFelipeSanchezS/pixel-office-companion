export const EVENT_VERSION = "1.0" as const;

export type EventType =
  | "activity.typing"
  | "activity.idle"
  | "ai.request.start"
  | "ai.request.stream"
  | "ai.request.end"
  | "outcome.test_pass"
  | "outcome.test_fail";

export type EventPayloads = {
  // activity.typing: minimal payload, no fields required
  "activity.typing": Record<string, never>;
  // activity.idle: idle duration in milliseconds
  "activity.idle": { duration_ms: number };
  // ai.request.start: optional request identifier if provided by the host
  "ai.request.start": { requestId?: string };
  // ai.request.stream: optional request identifier and chunk length in chars
  "ai.request.stream": { requestId?: string };
  // ai.request.end: optional request identifier if provided by the host
  "ai.request.end": { requestId?: string };
  // outcome.test_pass: exit code from a test task (0)
  "outcome.test_pass": Record<string, never>;
  // outcome.test_fail: exit code from a test task (non-zero or undefined)
  "outcome.test_fail": Record<string, never>;
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
