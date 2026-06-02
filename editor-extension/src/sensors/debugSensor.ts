import * as vscode from "vscode";
import { RawEvent } from "../protocol/eventTypes";

type EmitRaw = (event: RawEvent) => void;

export function registerDebugSensor(emit: EmitRaw): vscode.Disposable {
  const disposables: vscode.Disposable[] = [];

  disposables.push(
    vscode.debug.onDidStartDebugSession((session) => {
      emit({ type: "debug.session.start", payload: { debuggerType: session.type } });
    })
  );

  disposables.push(
    vscode.debug.onDidTerminateDebugSession((_session) => {
      emit({ type: "debug.session.end", payload: {} });
    })
  );

  disposables.push(
    vscode.debug.onDidChangeActiveStackItem((_item) => {
      emit({ type: "debug.session.step", payload: {} });
    })
  );

  return new vscode.Disposable(() => {
    for (const d of disposables) {
      d.dispose();
    }
  });
}
