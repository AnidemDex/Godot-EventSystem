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
	data = []
	_loading_subevents = false
	if timeline:
		var events = timeline.get_events()
		data = events
	update_view()


func is_loading() -> bool:
	return loading


func update_view() -> void:
	_notify_load_started()
	
	if data.empty():
		loaded_events.clear()
		for node in get_children():
			node.free()
		loaded_nodes.clear()
	
	
	if loaded_events.size() > data.size():
		for node in get_children():
			node.free()
		loaded_events.clear()
	
	if loaded_nodes.size() > data.size():
		for node in get_children():
			node.free()
		loaded_nodes.clear()
	
	
	for idx in data.size():
		var event = data[idx]
		if event in loaded_events:
			# already loaded
			continue
		var node := _get_event_node(event)
		add_child(node)
		loaded_nodes.append(node)
		loaded_events.append(event)
		
		var is_subnode = false
		is_subnode = event in _subevents_data
		if is_subnode:
			var original_node = _subevents_data[event]
			original_node.subevents[event] = node
			
		emit_signal("event_node_added", node)
	
	for idx in loaded_nodes.size():
		var event = loaded_nodes[idx].get("event")
		var real_idx = data.find(event)
		loaded_nodes[idx].get("idx").set("text", str(real_idx))
		move_child(loaded_nodes[idx], real_idx)
	
	
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
#	event_node.size_flags_horizontal = 0
	event_node.connect("subevent_requested", self, "_on_EventNode_subevent_requested")
	event_node.connect("subtimeline_requested", self, "_on_EventNode_subtimeline_requested")
	return event_node


func _notify_load_started() -> void:
	loading = true
	emit_signal("load_started")


func _notify_load_ended() -> void:
	loading = false
	emit_signal("load_ended")


func _handle_queued_subevents() -> void:
	if loading:
		return
	_notify_load_started()
	_loading_subevents = true
	if is_connected("load_ended", self, "_handle_queued_subevents"):
		disconnect("load_ended", self, "_handle_queued_subevents")
	
	for _data in subevent_queue:
		_on_EventNode_subevent_requested(_data[0], _data[1])
	subevent_queue.clear()
	update_view()
	_notify_load_ended()
	_loading_subevents = false


func _handle_queued_subtimelines() -> void:
	if loading:
		return
	
	
	_notify_load_started()
	
	if is_connected("load_ended", self, "_handle_queued_subtimelines"):
		disconnect("load_ended", self, "_handle_queued_subtimelines")
	
	# Needed this way since you can't cross reference classes in the same script or between script
	var SubtimelineDisplayer = load("res://addons/event_system_plugin/nodes/editor/subtimeline.gd")
	for data in subtimeline_queue:
		var node:Node = data[1]
		var subtimeline:Resource = data[0]
		var container:Control
		if node.has_meta("subtimeline_container") and is_instance_valid(node.get_meta("subtimeline_container")):
			container = node.get_meta("subtimeline_container")
		else:
			container = SubtimelineDisplayer.new()
			node.set_meta("subtimeline_container", container)
			add_child(container)
		
		var timeline_displayer = container.add_timeline_and_get_node(subtimeline)
		move_child(container, node.get_index()+1)
		node.subtimelines[subtimeline] = timeline_displayer
		
	
	subtimeline_queue.clear()
	_notify_load_ended()


func _on_EventNode_subevent_requested(resource, node) -> void:
	node.subevents[resource] = null
	if loading and not _loading_subevents:
		subevent_queue.append([resource, node])
		if not is_connected("load_ended", self, "_handle_queued_subevents"):
			connect("load_ended", self, "_handle_queued_subevents")
		return
	data.insert(data.find(node.event)+1, resource)
	_subevents_data[resource] = node


func _on_EventNode_subtimeline_requested(resource, node) -> void:
	node.subtimelines[resource] = null
		
	if loading:
		subtimeline_queue.append([resource, node])
		if not is_connected("load_ended", self, "_handle_queued_subtimelines"):
			connect("load_ended", self, "_handle_queued_subtimelines", [], CONNECT_DEFERRED)
		return


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = SIZE_EXPAND_FILL
