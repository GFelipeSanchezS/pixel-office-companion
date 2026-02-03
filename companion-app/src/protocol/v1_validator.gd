extends Node

const ALLOWED_TYPES := [
	"activity.typing",
	"activity.idle",
	"ai.request.start",
	"ai.request.stream",
	"ai.request.end",
	"outcome.test_pass",
	"outcome.test_fail"
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
	if event_type == "activity.typing":
		if not payload.has("intensity"):
			return { "ok": false, "error": "missing intensity" }
		var intensity = payload.intensity
		if typeof(intensity) != TYPE_STRING:
			return { "ok": false, "error": "invalid intensity" }
		if not ["low", "medium", "high"].has(intensity):
			return { "ok": false, "error": "invalid intensity" }
	elif event_type == "activity.idle":
		if not payload.has("duration_ms"):
			return { "ok": false, "error": "missing duration_ms" }
		if typeof(payload.duration_ms) != TYPE_INT and typeof(payload.duration_ms) != TYPE_FLOAT:
			return { "ok": false, "error": "invalid duration_ms" }
	elif event_type == "ai.request.start":
		if not payload.has("provider") or typeof(payload.provider) != TYPE_STRING:
			return { "ok": false, "error": "invalid provider" }
		if not payload.has("kind") or typeof(payload.kind) != TYPE_STRING:
			return { "ok": false, "error": "invalid kind" }
	elif event_type == "ai.request.stream":
		pass
	elif event_type == "ai.request.end":
		if not payload.has("outcome"):
			return { "ok": false, "error": "missing outcome" }
		if typeof(payload.outcome) != TYPE_STRING:
			return { "ok": false, "error": "invalid outcome" }
		if not ["success", "error"].has(payload.outcome):
			return { "ok": false, "error": "invalid outcome" }
	elif event_type == "outcome.test_pass":
		pass
	elif event_type == "outcome.test_fail":
		pass

	return { "ok": true, "error": "" }
