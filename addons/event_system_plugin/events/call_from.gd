tool
extends Event
class_name EventCall

## Makes a [code]call()[/code] to a method in a node with any number of arguments.

export(String) var method:String = "" setget set_method
export(Array) var args:Array = []

func _init() -> void:
	event_color = Color("EB5E55")
	event_name = "Call"
	event_category = "Node"
	event_preview_string = "{event_node_path} {method} ( {args} ) "

	args = []


func _execute() -> void:
	var node:Node = get_event_node()
	
	if node.has_method(method):
		node.callv(method, args)
	
	finish()


func set_method(value:String) -> void:
	method = value
	emit_changed()
	property_list_changed_notify()


func set_args(value:Array) -> void:
	args = value.duplicate()
	emit_changed()
	property_list_changed_notify()
