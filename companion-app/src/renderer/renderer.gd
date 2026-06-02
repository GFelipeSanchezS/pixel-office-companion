extends Node2D

@onready var _desk_workers: Array[AnimatedSprite2D] = [
	$Worker1, $Worker2, $Worker3, $Worker4
]
@onready var _rush_worker: AnimatedSprite2D = $RushWorker

var _desk_busy: Array[bool] = [false, false, false, false]
var _rush_busy: bool = false
var _away_worker_idx: int = -1

func _ready() -> void:
	_rush_worker.visible = false
	for worker in _desk_workers:
		worker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_rush_worker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for i in range(_desk_workers.size()):
		var idx = i
		_desk_workers[i].animation_finished.connect(func(): _on_desk_finished(idx))
	_rush_worker.animation_finished.connect(_on_rush_finished)
	for worker in _desk_workers:
		_play_if_exists(worker, "idle")

func on_state_changed(state: String) -> void:
	match state:
		"IDLE":
			_handle_idle()
		"AWAY":
			_handle_away()
		_:
			_dispatch(state.to_lower())

func _handle_idle() -> void:
	if _away_worker_idx < 0:
		return
	_desk_busy[_away_worker_idx] = false
	_play_if_exists(_desk_workers[_away_worker_idx], "idle")
	_away_worker_idx = -1

func _handle_away() -> void:
	var idx = _find_available_desk()
	if idx < 0:
		return
	_desk_busy[idx] = true
	_away_worker_idx = idx
	_play_if_exists(_desk_workers[idx], "falling_asleep")

func _dispatch(animation: String) -> void:
	var idx = _find_available_desk()
	if idx >= 0:
		_desk_busy[idx] = true
		_play_if_exists(_desk_workers[idx], animation)
		return
	if not _rush_busy:
		_rush_busy = true
		_rush_worker.visible = true
		_play_if_exists(_rush_worker, animation)

func _find_available_desk() -> int:
	for i in range(_desk_workers.size()):
		if not _desk_busy[i]:
			return i
	return -1

func _on_desk_finished(idx: int) -> void:
	if idx == _away_worker_idx:
		_play_if_exists(_desk_workers[idx], "sleeping")
		return
	_desk_busy[idx] = false
	_play_if_exists(_desk_workers[idx], "idle")

func _on_rush_finished() -> void:
	_rush_worker.visible = false
	_rush_busy = false

func _play_if_exists(sprite: AnimatedSprite2D, animation: String) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	if not sprite.sprite_frames.has_animation(animation):
		return
	sprite.play(animation)
