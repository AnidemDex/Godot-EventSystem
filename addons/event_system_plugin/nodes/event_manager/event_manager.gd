extends Node

signal event_started(event)
signal event_ended(event)

signal timeline_started(timeline_resource)
signal timeline_ended(timeline_resource)

export(NodePath) var event_node_path:NodePath = "."
export(bool) var start_on_ready:bool = false

var timeline:Timeline

func _ready() -> void:
	if Engine.editor_hint:
		return
	
	if start_on_ready:
		start_timeline()


func start_timeline(timeline_resource:Timeline=timeline) -> void:
	timeline = timeline_resource
	_notify_timeline_start()
	
	if timeline == null:
		_notify_timeline_end()
		return
		
	
	go_to_next_event()


func go_to_next_event() -> void:
	
	if timeline == null:
		_notify_timeline_end()
		return
	
	var _event_idx = timeline.last_event+1
	var event = timeline.get_next_event()
	
	if _event_idx > timeline.get_events().size():
		_notify_timeline_end()
		if not timeline.can_loop():
			return
	
	_execute_event(event)


func _execute_event(event:Event) -> void:
	var node:Node = self if event_node_path == @"." else get_node(event_node_path)
	node.set("_EventManager", self)
	event.execute(node)


func _notify_timeline_start() -> void:
	emit_signal("timeline_started")


func _notify_timeline_end() -> void:
	emit_signal("timeline_ended")
