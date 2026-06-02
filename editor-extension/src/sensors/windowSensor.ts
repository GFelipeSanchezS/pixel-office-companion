import * as vscode from "vscode";
import * as path from "path";
import { RawEvent } from "../protocol/eventTypes";

type EmitRaw = (event: RawEvent) => void;

export function registerWindowSensor(emit: EmitRaw): vscode.Disposable {
  const disposables: vscode.Disposable[] = [];

  disposables.push(
    vscode.window.onDidChangeWindowState((state) => {
      if (state.focused) {
        emit({ type: "activity.focus", payload: {} });
      } else {
        emit({ type: "activity.away", payload: {} });
      }
    })
  );

  disposables.push(
    vscode.window.onDidChangeActiveTextEditor((editor) => {
      if (!editor) {
        return;
      }
      emit({
        type: "editor.file.switch",
        payload: { fileName: path.basename(editor.document.fileName) },
      });
    })
  );

  return new vscode.Disposable(() => {
    for (const d of disposables) {
      d.dispose();
    }
  });
}
