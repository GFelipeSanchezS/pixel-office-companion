extends Node

var _client: Node
var _validator: Node

func _ready() -> void:
	_client = preload("res://src/transport/websocket_client.gd").new()
	_validator = preload("res://src/protocol/v1_validator.gd").new()
	add_child(_client)
	add_child(_validator)

	_client.connected.connect(_on_connected)
	_client.disconnected.connect(_on_disconnected)
	_client.message_received.connect(_on_message_received)

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
		print(parsed)
	else:
		print("invalid event: %s" % result.error)
