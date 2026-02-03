extends Node

signal connected
signal disconnected
signal message_received(message: String)

const URL := "ws://localhost:8787"
const RETRY_MS := 5000

var _peer: WebSocketPeer
var _last_state := WebSocketPeer.STATE_CLOSED
var _reconnect_timer: SceneTreeTimer

func start() -> void:
	_connect()

func _process(_delta: float) -> void:
	if _peer == null:
		return

	var state = _peer.get_ready_state()
	if state == WebSocketPeer.STATE_CONNECTING or state == WebSocketPeer.STATE_OPEN:
		_peer.poll()

	_handle_state_change(state)

	if state == WebSocketPeer.STATE_OPEN:
		while _peer.get_available_packet_count() > 0:
			var packet = _peer.get_packet()
			var text = packet.get_string_from_utf8()
			message_received.emit(text)

func _connect() -> void:
	_peer = WebSocketPeer.new()
	var err = _peer.connect_to_url(URL)
	if err != OK:
		_schedule_reconnect()

func _handle_state_change(state: int) -> void:
	if state == _last_state:
		return

	if state == WebSocketPeer.STATE_OPEN:
		connected.emit()
	elif state == WebSocketPeer.STATE_CLOSED:
		disconnected.emit()
		_schedule_reconnect()

	_last_state = state

func _schedule_reconnect() -> void:
	if _reconnect_timer != null:
		return
	_reconnect_timer = get_tree().create_timer(RETRY_MS / 1000.0)
	_reconnect_timer.timeout.connect(func() -> void:
		_reconnect_timer = null
		_connect()
	)
