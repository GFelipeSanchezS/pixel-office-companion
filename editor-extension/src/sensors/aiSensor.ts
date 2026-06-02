import * as vscode from "vscode";
import { RawEvent } from "../protocol/eventTypes";

type EmitRaw = (event: RawEvent) => void;

export function registerAiSensor(emit: EmitRaw): vscode.Disposable {
  const disposables: vscode.Disposable[] = [];
  const chat = (vscode as unknown as { chat?: any }).chat;

  if (chat?.onDidStartChatRequest) {
    disposables.push(
      chat.onDidStartChatRequest((_e: any) => {
        emit({ type: "ai.request.start", payload: { provider: "vscode", kind: "chat" } });
      })
    );
  }

  if (chat?.onDidReceiveChatResponse) {
    disposables.push(
      chat.onDidReceiveChatResponse((_e: any) => {
        emit({ type: "ai.request.stream", payload: {} });
      })
    );
  }

  if (chat?.onDidEndChatRequest) {
    disposables.push(
      chat.onDidEndChatRequest((_e: any) => {
        emit({ type: "ai.request.end", payload: { outcome: "success" } });
      })
    );
  }

  return new vscode.Disposable(() => {
    for (const disposable of disposables) {
      disposable.dispose();
    }
  });
}
