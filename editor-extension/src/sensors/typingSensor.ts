import * as vscode from "vscode";
import { RawEvent } from "../protocol/eventTypes";

type EmitRaw = (event: RawEvent) => void;

const DEFAULT_IDLE_MS = 5000;

export function registerTypingSensor(
  emit: EmitRaw,
  idleMs: number = DEFAULT_IDLE_MS
): vscode.Disposable {
  let idleTimer: NodeJS.Timeout | undefined;

  const resetIdleTimer = () => {
    if (idleTimer) {
      clearTimeout(idleTimer);
    }
    idleTimer = setTimeout(() => {
      emit({ type: "activity.idle", payload: { duration_ms: idleMs } });
    }, idleMs);
  };

  const onChange = vscode.workspace.onDidChangeTextDocument(() => {
    emit({ type: "activity.typing", payload: {} });
    resetIdleTimer();
  });

  return new vscode.Disposable(() => {
    onChange.dispose();
    if (idleTimer) {
      clearTimeout(idleTimer);
      idleTimer = undefined;
    }
  });
}
