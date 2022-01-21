tool
extends Event
class_name EventCondition

const _Utils = preload("res://addons/event_system_plugin/core/utils.gd")

export(String) var condition:String = "" setget set_condition
export(Resource) var events_if = Timeline.new() setget set_if_events
export(Resource) var events_else = Timeline.new() setget set_else_events


func _init() -> void:
	event_name = "Condition"
	event_color = Color("#FBB13C")
	event_icon = load("res://addons/event_system_plugin/assets/icons/event_icons/condition_event.png") as Texture
	event_preview_string = "If [ {condition} ]:"
	event_hint = "Similar to if-else statement.\nEvaluates a condition and execute events accordingly."
	event_category = "Logic"
	continue_at_end = true

	events_if = _get_empty_timeline("Timeline IF")

	events_else = _get_empty_timeline("Timeline ELSE")


func _execute() -> void:
	# TODO: replace with node variables
	var variables:Dictionary = {}
	
	var evaluated_condition = _Utils.evaluate(condition, event_node, variables)
	
	var timeline:Timeline
	var current_timeline:Timeline = event_manager.timeline
		
	if not current_timeline:
		finish()
		return
	
	if evaluated_condition and (str(evaluated_condition) != condition):
		timeline = events_if
	else:
		timeline = events_else
	
	if timeline:
		var _events:Array = timeline.get_events()
		current_timeline._event_queue = _events + current_timeline._event_queue
	
	
	finish()


func _get(property: String):
	if property == "continue_at_end_ignore":
		return true
	
	if property == "custom_event_node":
		return load("res://addons/event_system_plugin/nodes/editor/event_node/event_condition/event_node.tscn").instance()


func set_condition(value:String) -> void:
	condition = value
	emit_changed()
	property_list_changed_notify()


func set_if_events(value:Timeline) -> void:
	if events_if.is_connected("changed", self, "timeline_changed"):
		events_if.disconnect("changed", self, "timeline_changed")
	events_if = value
	if not events_if.is_connected("changed", self, "timeline_changed"):
		events_if.connect("changed", self, "timeline_changed")
	emit_changed()
	property_list_changed_notify()


func set_else_events(value:Timeline) -> void:
	if events_else.is_connected("changed", self, "timeline_changed"):
		events_else.disconnect("changed", self, "timeline_changed")
	events_else = value
	if not events_else.is_connected("changed", self, "timeline_changed"):
		events_else.connect("changed", self, "timeline_changed")
	emit_changed()
	property_list_changed_notify()


func timeline_changed() -> void:
	emit_changed()
	property_list_changed_notify()


func property_can_revert(property:String) -> bool:
	match property:
		"events_if", "events_else":
			return true
	return false


func property_get_revert(property:String): # -> Variant() type
	if property == "events_if":
		return _get_empty_timeline("Timeline IF")
	if property == "events_else":
		return _get_empty_timeline("Timeline ELSE")
	return null


func _get_empty_timeline(with_name:String) -> Timeline:
	var tmln := Timeline.new()
	if with_name != "":
		tmln.resource_name = with_name
	return tmln
