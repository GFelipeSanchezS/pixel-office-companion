extends Node

var _client: Node
var _validator: Node
var _state_machine: Node
var _renderer: Node

func _ready() -> void:
	_client = preload("res://src/transport/websocket_client.gd").new()
	_validator = preload("res://src/protocol/v1_validator.gd").new()
	_state_machine = preload("res://src/state/state_machine.gd").new()
	_renderer = preload("res://src/renderer/office_scene.tscn").instantiate()

	add_child(_client)
	add_child(_validator)
	add_child(_state_machine)
	add_child(_renderer)

	_client.connected.connect(_on_connected)
	_client.disconnected.connect(_on_disconnected)
	_client.message_received.connect(_on_message_received)
	_state_machine.state_changed.connect(_renderer.on_state_changed)

	_client.start()

func _on_connected() -> void:
	print("connected")

func _on_disconnected() -> void:
	print("disconnected")

func _on_message_received(message: String) -> void:
	var parsed = JSON.parse_string(message)
	if typeof(parsed) != TYPE_DICTIONARY:
		print("invalid event: not a JSON object")
		return

	var result = _validator.validate(parsed)
	if result.ok:
		_state_machine.on_event(parsed)
	else:
		print("invalid event: %s" % result.error)
