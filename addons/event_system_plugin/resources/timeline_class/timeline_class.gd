tool
extends Resource
class_name Timeline, "res://addons/event_system_plugin/assets/icons/timeline_icon.png"

# Can't reference:
#	- EventManager node

var last_event:int = -1

var _events:Array = []
var _can_loop:bool = false setget ,can_loop


func add_event(event, at_position=-1) -> void:
	if at_position >= 0:
		_events.insert(at_position, event)
	else:
		_events.append(event)
	emit_changed()


func erase_event(event) -> void:
	_events.erase(event)
	emit_changed()


func remove_event(position:int) -> void:
	_events.remove(position)
	emit_changed()


func get_events() -> Array:
	return _events.duplicate()


func get_next_event() -> Resource:
	if _events.empty():
		return null
	
	var next_event_idx:int = last_event+1
	if next_event_idx < _events.size():
		return _events[next_event_idx]
	
	if _can_loop:
		last_event = 0
	
	return _events[last_event]


func can_loop() -> bool:
	return _can_loop


func get_previous_event() -> Resource:
	if _events.empty():
		return null
	
	var prev_event_idx:int = last_event-1
	
	if prev_event_idx > -1:
		return _events[prev_event_idx]
	
	if _can_loop:
		last_event = _events.size()-1
	
	return _events[last_event]


func _init() -> void:
	_events = []


func _to_string() -> String:
	return "[{class}:{id}]".format({"class":"Timeline", "id":get_instance_id()})
