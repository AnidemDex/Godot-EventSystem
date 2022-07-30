tool
extends "res://addons/event_system_plugin/events/call_from.gd"
class_name EventSet

## Sets [code]variable_name[/code] be [code]variable_value[/code] in [code]event_node[/code].

export(String) var variable_name:String = "" setget set_var_name
export(String) var variable_value:String = "" setget set_var_value

func _init() -> void:
	event_name = "Set"
	event_category = "Node"
	event_color = Color("EB5E55")
	event_preview_string = "[ {variable_name} ] to be [ {variable_value} ]"
	continue_at_end = true
	method = "set"
	args = ["",""]


func set_var_name(value:String) -> void:
	variable_name = value
	args[0] = variable_name
	emit_changed()
	property_list_changed_notify()


func set_var_value(value:String) -> void:
	variable_value = value
	args[1] = variable_value
	emit_changed()
	property_list_changed_notify()


func _get(property: String):
	if property == "continue_at_end_ignore":
		return true
	if property == "method_ignore":
		return true
	if property == "args_ignore":
		return true
