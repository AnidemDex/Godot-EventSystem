tool
extends Resource
class_name Timeline, "res://addons/event_system_plugin/assets/icons/timeline_icon.png"

# Can't reference:
#	- EventManager node
#	- Event
# Note for future devs: Keep this resource as an event container. No magic tricks
var _events:Array = [] setget set_events
var _structure:Dictionary = {}

func set_events(events:Array) -> void:
	_events = events
	emit_changed()
	property_list_changed_notify()


func add_event(event) -> void:
	if has(event):
		push_error("add_event: Trying to add an event to the timeline, but the event is already added")
		return
	
	_events.append(event)
	
	update_structure()
	emit_changed()
	property_list_changed_notify()


func insert_event(event, at_position:int) -> void:
	if has(event):
		push_error("insert_event: Trying to add an event to the timeline, but the event already exist")
		return
	
	var idx = at_position if at_position > -1 else _events.size()
	_events.insert(idx, event)
	
	update_structure()
	emit_changed()
	property_list_changed_notify()


func move_event(event, to_position:int) -> void:
	if !has(event):
		push_error("move_event: Trying to move an event in the timeline, but the event is not added.")
		return
	
	var old_position:int = get_event_idx(event)
	if old_position < 0:
		return
	
	to_position = to_position if to_position > -1 else _events.size()
	if to_position == old_position:
		emit_changed()
		return
	
	_events.remove(old_position)
	
	if to_position < 0 or to_position > _events.size():
		to_position = _events.size()
	
	_events.insert(to_position, event)
	
	update_structure()
	emit_changed()
	property_list_changed_notify()
	


func erase_event(event) -> void:
	_events.erase(event)
	update_structure()
	emit_changed()
	property_list_changed_notify()


func remove_event(position:int) -> void:
	_events.remove(position)
	update_structure()
	emit_changed()
	property_list_changed_notify()


func event_is_subevent_of(event, of_event) -> bool:
	if of_event in _structure:
		return event in _structure.get(of_event, [])
	return false


func get_event_subevents(event) -> Array:
	var subevents:Array = []
	if event in _structure:
		subevents = _structure.get(event, [])
	return subevents


func update_structure() -> void:
	var subevent_holders := []
	
	for event in _events:
		_structure[event] = []
		event.set("event_subevent_from", null)
		event.set("event_indent_level", 0)
		if event.get("event_uses_subevents"):
			subevent_holders.append(event)
	
	_structure["subevent_holders"] = subevent_holders
	
	for event in subevent_holders:
		var from_here := false
		var sub_ev_counter := 0
		
		for sub_ev in _events:
			if from_here:
				sub_ev_counter += 1
				if sub_ev_counter > event.get("event_subevents_quantity"):
					break
				_structure[event].append(sub_ev)
				sub_ev.set("event_subevent_from", weakref(event))
				sub_ev.set("event_indent_level", event.get("event_indent_level")+1)
			
			elif sub_ev != event:
				continue
			
			from_here = true
		
		if sub_ev_counter < 1:
			event.set("event_subevents_quantity", 0)


func has(event:Resource) -> bool:
	return _events.has(event)


func get_event_idx(event) -> int:
	return _events.find(event)


func get_events() -> Array:
	return _events.duplicate()


func _set(property:String, value) -> bool:
	var has_property := false
	
	if property.begins_with("event/"):
		var event_idx:int = int(property.split("/", true, 2)[1])
		if event_idx < _events.size():
			_events[event_idx] = value
		else:
			_events.insert(event_idx, value)
		
		has_property = true
		emit_changed()
	
	return has_property


func _get(property:String):
	if property.begins_with("event/"):
		var event_idx:int = int(property.split("/", true, 2)[1])
		if event_idx < _events.size():
			return _events[event_idx]


func _init() -> void:
	_events = []
	_structure = {}
	resource_name = get_class()


func _to_string() -> String:
	return "[{class}:{id}]".format({"class":get_class(), "id":get_instance_id()})


func get_class() -> String: return "Timeline"


func _get_property_list() -> Array:
	var p = []
	for event_idx in _events.size():
		p.append(
			{
				"name":"event/{idx}".format({"idx":event_idx}),
				"type":TYPE_OBJECT,
				"usage":PROPERTY_USAGE_DEFAULT|PROPERTY_USAGE_SCRIPT_VARIABLE
			}
		)
	return p
