tool
extends "res://addons/event_system_plugin/resources/timeline_class/timeline_class.gd"

## This file stores events displayed in the editor toolbar.

func _init():
	var events = [
		load("res://addons/event_system_plugin/events/call_from.gd").new(),
		load("res://addons/event_system_plugin/events/comment.gd").new(),
		load("res://addons/event_system_plugin/events/emit_signal.gd").new(),
		load("res://addons/event_system_plugin/events/end_timeline.gd").new(),
		load("res://addons/event_system_plugin/events/hide.gd").new(),
		load("res://addons/event_system_plugin/events/condition.gd").new(),
		load("res://addons/event_system_plugin/events/set.gd").new(),
		load("res://addons/event_system_plugin/events/show.gd").new(),
		load("res://addons/event_system_plugin/events/wait.gd").new(),
		load("res://addons/event_system_plugin/events/goto.gd").new()
		]
	
	for ev in events:
		register_event(ev)


func register_event(event) -> void:
	if event == null:
		return
	
	var _scripts := []
	for _event in _events:
		_scripts.append((event as Resource).get_script())
	
	if event.get_script() in _scripts:
		return
	
	add_event(event)
