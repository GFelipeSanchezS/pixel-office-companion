extends Node

const ALLOWED_TYPES := [
	"activity.typing",
	"activity.idle",
	"activity.focus",
	"activity.away",
	"ai.request.start",
	"ai.request.stream",
	"ai.request.end",
	"debug.session.start",
	"debug.session.end",
	"debug.session.step",
	"editor.file.switch",
	"editor.file.create",
	"editor.file.delete",
	"editor.file.rename",
	"outcome.test_pass",
	"outcome.test_fail",
	"task.process.start",
	"terminal.command.end"
]

func validate(event: Dictionary) -> Dictionary:
	var required_fields = ["version", "id", "timestamp", "type", "payload"]
	for field in required_fields:
		if not event.has(field):
			return { "ok": false, "error": "missing field: %s" % field }

	if event.version != "1.0":
		return { "ok": false, "error": "invalid version" }

	if typeof(event.type) != TYPE_STRING or not ALLOWED_TYPES.has(event.type):
		return { "ok": false, "error": "invalid type" }

	if typeof(event.payload) != TYPE_DICTIONARY:
		return { "ok": false, "error": "payload must be an object" }

	return _validate_payload(event.type, event.payload)

func _validate_payload(event_type: String, payload: Dictionary) -> Dictionary:
	match event_type:
		"activity.typing":
			if not payload.has("intensity") or typeof(payload.intensity) != TYPE_STRING:
				return { "ok": false, "error": "missing or invalid intensity" }
			if not ["low", "medium", "high"].has(payload.intensity):
				return { "ok": false, "error": "invalid intensity value" }
		"activity.idle":
			if not payload.has("duration_ms"):
				return { "ok": false, "error": "missing duration_ms" }
			if typeof(payload.duration_ms) != TYPE_INT and typeof(payload.duration_ms) != TYPE_FLOAT:
				return { "ok": false, "error": "invalid duration_ms" }
		"activity.focus", "activity.away":
			pass
		"ai.request.start":
			if not payload.has("provider") or typeof(payload.provider) != TYPE_STRING:
				return { "ok": false, "error": "invalid provider" }
			if not payload.has("kind") or typeof(payload.kind) != TYPE_STRING:
				return { "ok": false, "error": "invalid kind" }
		"ai.request.stream":
			pass
		"ai.request.end":
			if not payload.has("outcome") or typeof(payload.outcome) != TYPE_STRING:
				return { "ok": false, "error": "missing or invalid outcome" }
			if not ["success", "error"].has(payload.outcome):
				return { "ok": false, "error": "invalid outcome value" }
		"debug.session.start":
			if not payload.has("debuggerType") or typeof(payload.debuggerType) != TYPE_STRING:
				return { "ok": false, "error": "missing or invalid debuggerType" }
		"debug.session.end", "debug.session.step":
			pass
		"editor.file.switch":
			if not payload.has("fileName") or typeof(payload.fileName) != TYPE_STRING:
				return { "ok": false, "error": "missing or invalid fileName" }
		"editor.file.create", "editor.file.delete":
			if not payload.has("files") or typeof(payload.files) != TYPE_ARRAY:
				return { "ok": false, "error": "missing or invalid files" }
		"editor.file.rename":
			if not payload.has("oldName") or typeof(payload.oldName) != TYPE_STRING:
				return { "ok": false, "error": "missing or invalid oldName" }
			if not payload.has("newName") or typeof(payload.newName) != TYPE_STRING:
				return { "ok": false, "error": "missing or invalid newName" }
		"outcome.test_pass", "outcome.test_fail":
			pass
		"task.process.start":
			if not payload.has("taskName") or typeof(payload.taskName) != TYPE_STRING:
				return { "ok": false, "error": "missing or invalid taskName" }
		"terminal.command.end":
			if not payload.has("exitCode"):
				return { "ok": false, "error": "missing exitCode" }
			if payload.exitCode != null and typeof(payload.exitCode) != TYPE_INT and typeof(payload.exitCode) != TYPE_FLOAT:
				return { "ok": false, "error": "invalid exitCode" }

	return { "ok": true, "error": "" }
