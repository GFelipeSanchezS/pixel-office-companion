import { readFileSync } from "fs";
import { resolve } from "path";
import Ajv from "ajv";

type TimelineEntry = {
  delay_ms: number;
  event: unknown;
};

export type Timeline = TimelineEntry[];

const schemaPath = resolve(__dirname, "../../..", "protocol/schema/event.v1.json");
const timelinePath = resolve(__dirname, "timelines/basic.json");

export function loadTimeline(): Timeline {
  const schema = JSON.parse(readFileSync(schemaPath, "utf8"));
  const timeline = JSON.parse(readFileSync(timelinePath, "utf8"));

  if (!Array.isArray(timeline)) {
    throw new Error("Timeline must be an array.");
  }

  const ajv = new Ajv({ allErrors: true, strict: true });
  const validate = ajv.compile(schema);

  for (const entry of timeline) {
    if (
      typeof entry !== "object" ||
      entry === null ||
      typeof entry.delay_ms !== "number" ||
      !("event" in entry)
    ) {
      throw new Error("Invalid timeline entry shape.");
    }

    const isValid = validate(entry.event);
    if (!isValid) {
      const message = ajv.errorsText(validate.errors);
      throw new Error(`Invalid event in timeline: ${message}`);
    }
  }

  return timeline as Timeline;
}
