extends Node

const States = preload("res://src/state/states.gd")

signal state_changed(new_state: String)

var current_state: String = States.IDLE

var _decay_deadline_ms: int = 0

const _DECAY_TYPING_MS      := 2000
const _DECAY_THINKING_MS    := 10000
const _DECAY_SUCCESS_MS     := 3000
const _DECAY_ERROR_MS       := 5000
const _DECAY_DEBUGGING_MS   := 30000
const _DECAY_RUNNING_MS     := 60000
const _DECAY_TERMINAL_MS    := 3000
const _DECAY_FILE_SWITCH_MS := 1000
const _DECAY_FILE_OP_MS     := 2000

func _process(_delta: float) -> void:
	if _decay_deadline_ms <= 0:
		return
	if _now_ms() >= _decay_deadline_ms:
		_set_state(States.IDLE)
		_decay_deadline_ms = 0

func on_event(event: Dictionary) -> void:
	if not event.has("type"):
		return

	match event.type:
		"activity.typing":
			_set_state(States.TYPING)
			_set_decay(_DECAY_TYPING_MS)
		"activity.idle":
			_set_state(States.IDLE)
			_decay_deadline_ms = 0
		"activity.away":
			_set_state(States.AWAY)
			_decay_deadline_ms = 0
		"activity.focus":
			_set_state(States.IDLE)
			_decay_deadline_ms = 0
		"ai.request.start":
			_set_state(States.THINKING)
			_set_decay(_DECAY_THINKING_MS)
		"ai.request.stream":
			_set_state(States.THINKING)
			_set_decay(_DECAY_THINKING_MS)
		"ai.request.end":
			var payload = event.get("payload", {})
			if payload.get("outcome") == "success":
				_set_state(States.SUCCESS)
				_set_decay(_DECAY_SUCCESS_MS)
			elif payload.get("outcome") == "error":
				_set_state(States.ERROR)
				_set_decay(_DECAY_ERROR_MS)
		"debug.session.start":
			_set_state(States.DEBUGGING)
			_set_decay(_DECAY_DEBUGGING_MS)
		"debug.session.end":
			_set_state(States.IDLE)
			_decay_deadline_ms = 0
		"debug.session.step":
			_set_state(States.DEBUGGING)
			_set_decay(_DECAY_DEBUGGING_MS)
		"task.process.start":
			_set_state(States.RUNNING)
			_set_decay(_DECAY_RUNNING_MS)
		"outcome.test_pass":
			_set_state(States.SUCCESS)
			_set_decay(_DECAY_SUCCESS_MS)
		"outcome.test_fail":
			_set_state(States.ERROR)
			_set_decay(_DECAY_ERROR_MS)
		"terminal.command.end":
			_set_state(States.TERMINAL)
			_set_decay(_DECAY_TERMINAL_MS)
		"editor.file.switch":
			_set_state(States.FILE_SWITCH)
			_set_decay(_DECAY_FILE_SWITCH_MS)
		"editor.file.create":
			_set_state(States.FILE_CREATE)
			_set_decay(_DECAY_FILE_OP_MS)
		"editor.file.delete":
			_set_state(States.FILE_DELETE)
			_set_decay(_DECAY_FILE_OP_MS)
		"editor.file.rename":
			_set_state(States.FILE_RENAME)
			_set_decay(_DECAY_FILE_OP_MS)

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
