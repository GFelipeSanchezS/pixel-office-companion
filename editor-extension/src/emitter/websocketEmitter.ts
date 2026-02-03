import WebSocket from "ws";
import { NormalizedEvent } from "../protocol/eventTypes";

export class WebsocketEmitter {
  private readonly url = "ws://localhost:8787";
  private readonly retryMs = 5000;
  private socket: WebSocket | undefined;
  private retryTimer: NodeJS.Timeout | undefined;

  constructor() {
    this.connect();
  }

  send(event: NormalizedEvent): void {
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) {
      return;
    }
    try {
      this.socket.send(JSON.stringify(event));
    } catch {
      // Drop silently by requirement.
    }
  }

  dispose(): void {
    if (this.retryTimer) {
      clearTimeout(this.retryTimer);
      this.retryTimer = undefined;
    }
    if (this.socket) {
      this.socket.close();
      this.socket = undefined;
    }
  }

  private connect(): void {
    if (this.socket) {
      if (
        this.socket.readyState === WebSocket.OPEN ||
        this.socket.readyState === WebSocket.CONNECTING
      ) {
        return;
      }
    }

    this.socket = new WebSocket(this.url);
    this.socket.on("close", () => this.scheduleReconnect());
    this.socket.on("error", () => this.scheduleReconnect());
  }

  private scheduleReconnect(): void {
    if (this.retryTimer) {
      return;
    }
    this.retryTimer = setTimeout(() => {
      this.retryTimer = undefined;
      this.connect();
    }, this.retryMs);
  }
}
