tool
extends VBoxContainer

class Data:
	var loaded_events := []
	var loaded_nodes := []
	var related_nodes := []
	
	func has(resource) -> bool:
		return resource in loaded_events
	
	func has_node(resource) -> bool:
		return is_instance_valid(get_node(resource))
	
	func get_node(resource) -> Control:
		var idx = loaded_events.find(loaded_events)
		var node = null
		if idx > -1:
			node = loaded_nodes[idx]
		return node
	
	func remove_node(resource) -> void:
		if is_instance_valid(get_node(resource)):
			get_node(resource).queue_free()
	
	
	func remove_related_node(resource) -> void:
		pass
	
	func add_event(event, at_position = -1):
		if at_position < 0:
#			print("Adding %s at the end"%event)
			loaded_events.append(event)
			loaded_nodes.append(null)
			related_nodes.append(null)
		
		elif loaded_events.size() > at_position:
			if loaded_events[at_position] != event:
#				print("There's an event at that position, replacing %s for %s"%[loaded_events[at_position], event])
				loaded_events[at_position] = event
#			else:
#				print("-> %s Already loaded!"%event)
		else:
			loaded_events.resize(at_position+1)
			loaded_events[at_position] = event
			
			loaded_nodes.resize(at_position+1)
			related_nodes.resize(at_position+1)
			#print("Specific position, but the current array is smaller than that, resizing.")
	
	
	func get_event(at_position:int):
		if at_position < loaded_events.size():
			return loaded_events[at_position]
		return null
	
	func get_related_node(for_event):
		return null
	
	func resize(size):
		loaded_events.resize(size)
	
	
	func clear():
		loaded_events = []
		loaded_nodes = []
		related_nodes = []
	
	
	func _to_string() -> String:
		var a = ""
		a += "Loaded data:\n"
		for data_idx in loaded_events.size():
			var event = get_event(data_idx)
			var node = get_node(event)
			var r_node = get_related_node(event)
			a += "{0}\t{1}\t{2}\n".format([event, node, r_node])
		return a


signal event_node_added(event_node)
signal load_started
signal load_ended

const EventNode = preload("res://addons/event_system_plugin/nodes/editor/event_node/event_node.gd")

var loaded_data := Data.new()

var loading := false

var _last_loaded_node:Node


func load_timeline(timeline) -> void:
	if timeline:
		var events = timeline.get_events()
		prints("loading", events)
		for event_idx in events.size():
			loaded_data.add_event(events[event_idx], event_idx)
		loaded_data.resize(events.size())
		print(loaded_data)
		print(loaded_data.loaded_events)
		print(loaded_data.loaded_nodes)
		print(loaded_data.related_nodes)


func is_loading() -> bool:
	return loading


func update_view() -> void:
	pass

func remove_all_displayed_events() -> void:
	loaded_data.clear()
	for child in get_children():
		child.queue_free()


func _get_event_node(event:Event) -> EventNode:
	if not event:
		return null
	
	if loaded_data.has_node(event):
		return loaded_data.get_node(event) as EventNode
	
	var event_node:EventNode
	event_node = event.get("custom_event_node") as EventNode
	if event_node == null:
		event_node = EventNode.new()
	
	event_node.event = event
#	event_node.size_flags_horizontal = 0
	event_node.connect("subevent_requested", self, "_on_EventNode_subevent_requested")
	event_node.connect("subtimeline_requested", self, "_on_EventNode_subtimeline_requested")
	return event_node


func _load_ended() -> void:
	loading = false
	emit_signal("load_ended")


func _on_EventNode_subevent_requested(resource, node) -> void:
#	return
	print("Adding subevent")
	node.subevents[resource] = null
	if loading:
		print("Displayer busy, waiting...")
		if not is_connected("load_ended", self, "_on_EventNode_subevent_requested"):
			connect("load_ended", self, "_on_EventNode_subevent_requested", [resource, node], CONNECT_ONESHOT)
		return
	


func _on_EventNode_subtimeline_requested(resource, node) -> void:
	pass


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = SIZE_EXPAND_FILL
	add_constant_override("separation", 0)
