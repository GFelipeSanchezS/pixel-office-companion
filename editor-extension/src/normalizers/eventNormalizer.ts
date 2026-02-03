import { randomUUID } from "crypto";
import { EVENT_VERSION, NormalizedEvent, RawEvent } from "../protocol/eventTypes";

export function normalizeEvent(event: RawEvent): NormalizedEvent {
  return {
    version: EVENT_VERSION,
    id: randomUUID(),
    timestamp: new Date().toISOString(),
    type: event.type,
    payload: event.payload,
  };
}
