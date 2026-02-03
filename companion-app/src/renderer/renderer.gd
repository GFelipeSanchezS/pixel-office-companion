extends Node2D

@onready var _background: Sprite2D = $Background
@onready var _character: AnimatedSprite2D = $Character

func _ready() -> void:
	_set_pixel_filters()
	_configure_animation_loops()

func on_state_changed(state: String) -> void:
	if _character == null or _character.sprite_frames == null:
		return
	var animation = state.to_lower()
	if not _character.sprite_frames.has_animation(animation):
		return
	_configure_animation_loop(animation)
	_character.play(animation)

func _set_pixel_filters() -> void:
	if _background != null:
		_background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if _character != null:
		_character.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _configure_animation_loops() -> void:
	if _character == null or _character.sprite_frames == null:
		return
	for animation in _character.sprite_frames.get_animation_names():
		_configure_animation_loop(animation)

func _configure_animation_loop(animation: String) -> void:
	if _character == null or _character.sprite_frames == null:
		return
	var loop = not (animation == "success" or animation == "error")
	_character.sprite_frames.set_animation_loop(animation, loop)
