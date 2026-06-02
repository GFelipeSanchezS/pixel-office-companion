import * as vscode from "vscode";
import { normalizeEvent } from "./normalizers/eventNormalizer";
import { WebsocketEmitter } from "./emitter/websocketEmitter";
import { RawEvent } from "./protocol/eventTypes";
import { registerTypingSensor } from "./sensors/typingSensor";
import { registerAiSensor } from "./sensors/aiSensor";
import { registerTestSensor } from "./sensors/testSensor";
import { registerWindowSensor } from "./sensors/windowSensor";
import { registerDebugSensor } from "./sensors/debugSensor";
import { registerFileSensor } from "./sensors/fileSensor";
import { registerTerminalSensor } from "./sensors/terminalSensor";

export function activate(context: vscode.ExtensionContext): void {
  const emitter = new WebsocketEmitter();
  const cfg = vscode.workspace.getConfiguration("pixelOfficeCompanion.sensors");

  const emitRaw = (event: RawEvent) => {
    const normalized = normalizeEvent(event);
    emitter.send(normalized);
  };

  const sensors: vscode.Disposable[] = [];

  if (cfg.get<boolean>("typing", true)) {
    sensors.push(registerTypingSensor(emitRaw));
  }
  if (cfg.get<boolean>("ai", true)) {
    sensors.push(registerAiSensor(emitRaw));
  }
  if (cfg.get<boolean>("tests", true)) {
    sensors.push(registerTestSensor(emitRaw));
  }
  if (cfg.get<boolean>("debug", true)) {
    sensors.push(registerDebugSensor(emitRaw));
  }
  if (cfg.get<boolean>("window", true)) {
    sensors.push(registerWindowSensor(emitRaw));
  }
  if (cfg.get<boolean>("files", true)) {
    sensors.push(registerFileSensor(emitRaw));
  }
  if (cfg.get<boolean>("terminal", true)) {
    sensors.push(registerTerminalSensor(emitRaw));
  }

  context.subscriptions.push(
    ...sensors,
    new vscode.Disposable(() => emitter.dispose())
  );
}

export function deactivate(): void {
  // Disposables handle cleanup.
}
