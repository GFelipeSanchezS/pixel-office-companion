import * as vscode from "vscode";
import { RawEvent } from "../protocol/eventTypes";

type EmitRaw = (event: RawEvent) => void;

export function registerAiSensor(emit: EmitRaw): vscode.Disposable {
  const disposables: vscode.Disposable[] = [];
  const chat = (vscode as unknown as { chat?: any }).chat;

  if (chat?.onDidStartChatRequest) {
    disposables.push(
      chat.onDidStartChatRequest((e: any) => {
        const payload: { requestId?: string } = {};
        const requestId = e?.requestId ?? e?.id;
        if (typeof requestId === "string") {
          payload.requestId = requestId;
        }
        emit({ type: "ai.request.start", payload });
      })
    );
  }

  if (chat?.onDidReceiveChatResponse) {
    disposables.push(
      chat.onDidReceiveChatResponse((e: any) => {
        const payload: { requestId?: string; chunkLength?: number } = {};
        const requestId = e?.requestId ?? e?.id;
        if (typeof requestId === "string") {
          payload.requestId = requestId;
        }
        emit({ type: "ai.request.stream", payload });
      })
    );
  }

  if (chat?.onDidEndChatRequest) {
    disposables.push(
      chat.onDidEndChatRequest((e: any) => {
        const payload: { requestId?: string } = {};
        const requestId = e?.requestId ?? e?.id;
        if (typeof requestId === "string") {
          payload.requestId = requestId;
        }
        emit({ type: "ai.request.end", payload });
      })
    );
  }

  return new vscode.Disposable(() => {
    for (const disposable of disposables) {
      disposable.dispose();
    }
  });
}
