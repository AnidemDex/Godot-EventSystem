tool
extends VBoxContainer

signal event_node_added(event_node)
signal subtimeline_node_added(event_node)
signal load_started
signal load_ended

const EventNode = preload("res://addons/event_system_plugin/nodes/editor/event_node/event_node.gd")

var data := []
var loading := false

var subtimeline_queue := []
var subevent_queue := []

var loaded_nodes := []
var loaded_events := []

var _last_loaded_node:Node
var _loading_subevents := false
var _subevents_data := {}


func load_timeline(timeline) -> void:
	data = timeline.get_events()
	update_view()


func is_loading() -> bool:
	return loading


func update_view() -> void:
	_notify_load_started()
	for event in data:
		var event_node = _get_event_node(event)
		add_child(event_node)
		emit_signal("event_node_added", event_node)
	_notify_load_ended()


func remove_all_displayed_events() -> void:
	for child in get_children():
		child.queue_free()


func _get_event_node(event:Event) -> EventNode:
	if not event:
		return null
	
	var event_node:EventNode
	event_node = event.get("custom_event_node") as EventNode
	if event_node == null:
		event_node = EventNode.new()
	
	event_node.event = event
	return event_node


func _notify_load_started() -> void:
	loading = true
	emit_signal("load_started")


func _notify_load_ended() -> void:
	loading = false
	emit_signal("load_ended")
	queue_sort()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	rect_min_size = Vector2(128, 32)
