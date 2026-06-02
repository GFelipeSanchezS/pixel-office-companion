import * as vscode from "vscode";
import * as path from "path";
import { RawEvent } from "../protocol/eventTypes";

type EmitRaw = (event: RawEvent) => void;

export function registerFileSensor(emit: EmitRaw): vscode.Disposable {
  const disposables: vscode.Disposable[] = [];

  disposables.push(
    vscode.workspace.onDidCreateFiles((e) => {
      emit({
        type: "editor.file.create",
        payload: { files: e.files.map((uri) => path.basename(uri.fsPath)) },
      });
    })
  );

  disposables.push(
    vscode.workspace.onDidDeleteFiles((e) => {
      emit({
        type: "editor.file.delete",
        payload: { files: e.files.map((uri) => path.basename(uri.fsPath)) },
      });
    })
  );

  disposables.push(
    vscode.workspace.onDidRenameFiles((e) => {
      for (const { oldUri, newUri } of e.files) {
        emit({
          type: "editor.file.rename",
          payload: {
            oldName: path.basename(oldUri.fsPath),
            newName: path.basename(newUri.fsPath),
          },
        });
      }
    })
  );

  return new vscode.Disposable(() => {
    for (const d of disposables) {
      d.dispose();
    }
  });
}
