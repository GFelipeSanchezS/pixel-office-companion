import * as vscode from "vscode";
import { RawEvent } from "../protocol/eventTypes";

type EmitRaw = (event: RawEvent) => void;

export function registerTerminalSensor(emit: EmitRaw): vscode.Disposable {
  const onDidEnd = vscode.window.onDidEndTerminalShellExecution((e) => {
    emit({
      type: "terminal.command.end",
      payload: { exitCode: e.exitCode ?? null },
    });
  });

  return new vscode.Disposable(() => {
    onDidEnd.dispose();
  });
}
