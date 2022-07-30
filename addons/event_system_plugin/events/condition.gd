tool
extends Event
class_name EventCondition

## Conditional event that executes true events if the evaluated [code]condition[/code]
##
## Works like if-statements. The [code]condition[/code] is evaluated according the
## assigned [code]event_node[/code]

const _Utils = preload("res://addons/event_system_plugin/core/utils.gd")

export(String) var condition:String = ""

var next_event

func _execute() -> void:
	var variables:Dictionary = _Utils.get_property_values_from(get_event_node())
	
	var evaluated_condition = _Utils.evaluate(condition, get_event_node(), variables)
	
	if evaluated_condition and (str(evaluated_condition) != condition):
		next_event
	else:
		next_event
	
	next_event = "0"
	
	finish()


func _get(property: String):
	if property == "custom_event_node":
		return load("res://addons/event_system_plugin/nodes/editor/event_node/event_condition_node.gd").new()


func _init() -> void:
	event_name = "Condition"
	event_color = Color("#FBB13C")
	event_preview_string = "[ {condition} ]:"
	event_hint = "Similar to if-else statement.\nEvaluates a condition and execute events accordingly."
	event_category = "Logic"
	continue_at_end = true
	event_uses_subevents = true


func _get_property_list() -> Array:
	var p := []
	
	var usage:int = PROPERTY_USAGE_EDITOR
	usage |= PROPERTY_USAGE_STORAGE
	p.append({"name":"_events_if", "type":TYPE_OBJECT, "usage":usage})
	
	p.append({"name":"_events_else","type":TYPE_OBJECT, "usage":usage})
	return p
