tool
extends "res://addons/event_system_plugin/events/call_from.gd"
class_name EventHide

## Makes the [code]event_node[/code] be hidden if possible.

func _init() -> void:
	event_color = Color("EB5E55")
	event_name = "Hide"
	event_category = "Node"
	method = "set"
	args = ["visible", false]
	event_preview_string = "{event_node_path}"


func _get(property: String):
	if property == "method_ignore":
		return true
	if property == "args_ignore":
		return true
