import * as vscode from "vscode";
import { RawEvent } from "../protocol/eventTypes";

type EmitRaw = (event: RawEvent) => void;

export function registerTestSensor(emit: EmitRaw): vscode.Disposable {
  const onDidEndTaskProcess = vscode.tasks.onDidEndTaskProcess((e) => {
    const task = e.execution.task;
    if (task.group !== vscode.TaskGroup.Test) {
      return;
    }

    const exitCode = e.exitCode;
    if (exitCode === 0) {
      emit({ type: "outcome.test_pass", payload: {} });
    } else {
      emit({ type: "outcome.test_fail", payload: {} });
    }    
  });

  return new vscode.Disposable(() => {
    onDidEndTaskProcess.dispose();
  });
}
