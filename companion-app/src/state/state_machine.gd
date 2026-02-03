extends Node

signal state_changed(new_state: String)

var current_state: String = States.IDLE

var _decay_deadline_ms: int = 0

const _DECAY_TYPING_MS := 2000
const _DECAY_THINKING_MS := 10000
const _DECAY_SUCCESS_MS := 3000
const _DECAY_ERROR_MS := 5000

func _process(_delta: float) -> void:
	if _decay_deadline_ms <= 0:
		return
	var now_ms = _now_ms()
	if now_ms >= _decay_deadline_ms:
		_set_state(States.IDLE)
		_decay_deadline_ms = 0

func on_event(event: Dictionary) -> void:
	if not event.has("type"):
		return

	var event_type = event.type
	var payload = event.get("payload", {})

	if event_type == "activity.typing":
		_set_state(States.TYPING)
		_set_decay(_DECAY_TYPING_MS)
	elif event_type == "activity.idle":
		_set_state(States.IDLE)
		_decay_deadline_ms = 0
	elif event_type == "ai.request.start":
		_set_state(States.THINKING)
		_set_decay(_DECAY_THINKING_MS)
	elif event_type == "ai.request.stream":
		_set_state(States.THINKING)
		_set_decay(_DECAY_THINKING_MS)
	elif event_type == "ai.request.end":
		if typeof(payload) == TYPE_DICTIONARY and payload.has("outcome"):
			if payload.outcome == "success":
				_set_state(States.SUCCESS)
				_set_decay(_DECAY_SUCCESS_MS)
			elif payload.outcome == "error":
				_set_state(States.ERROR)
				_set_decay(_DECAY_ERROR_MS)
	elif event_type == "outcome.test_pass":
		_set_state(States.SUCCESS)
		_set_decay(_DECAY_SUCCESS_MS)
	elif event_type == "outcome.test_fail":
		_set_state(States.ERROR)
		_set_decay(_DECAY_ERROR_MS)

func _set_state(next_state: String) -> void:
	if current_state == next_state:
		return
	current_state = next_state
	state_changed.emit(current_state)

func _set_decay(duration_ms: int) -> void:
	if duration_ms <= 0:
		_decay_deadline_ms = 0
		return
	_decay_deadline_ms = _now_ms() + duration_ms

func _now_ms() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0)
