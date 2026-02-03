import * as vscode from "vscode";
import { normalizeEvent } from "./normalizers/eventNormalizer";
import { WebsocketEmitter } from "./emitter/websocketEmitter";
import { RawEvent } from "./protocol/eventTypes";
import { registerTypingSensor } from "./sensors/typingSensor";
import { registerAiSensor } from "./sensors/aiSensor";
import { registerTestSensor } from "./sensors/testSensor";

export function activate(context: vscode.ExtensionContext): void {
  const emitter = new WebsocketEmitter();

  const emitRaw = (event: RawEvent) => {
    const normalized = normalizeEvent(event);
    emitter.send(normalized);
  };

  context.subscriptions.push(
    registerTypingSensor(emitRaw),
    registerAiSensor(emitRaw),
    registerTestSensor(emitRaw),
    new vscode.Disposable(() => emitter.dispose())
  );
}

export function deactivate(): void {
  // Disposables handle cleanup.
}
