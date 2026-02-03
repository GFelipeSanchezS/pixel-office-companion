import WebSocket, { WebSocketServer } from "ws";
import { loadTimeline, Timeline } from "./timeline";

const PORT = 8787;

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function runTimeline(timeline: Timeline, wss: WebSocketServer): Promise<void> {
  let index = 0;
  while (true) {
    const entry = timeline[index];
    await delay(entry.delay_ms);
    const payload = JSON.stringify(entry.event);
    for (const client of wss.clients) {
      if (client.readyState === WebSocket.OPEN) {
        client.send(payload);
      }
    }
    index = (index + 1) % timeline.length;
  }
}

async function main(): Promise<void> {
  const timeline = loadTimeline();
  if (timeline.length === 0) {
    throw new Error("Timeline must contain at least one event.");
  }

  const wss = new WebSocketServer({ port: PORT });
  runTimeline(timeline, wss).catch((err) => {
    throw err;
  });
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
