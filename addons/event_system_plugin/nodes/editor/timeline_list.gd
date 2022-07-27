tool
extends OptionButton

const EvManager = preload("res://addons/event_system_plugin/nodes/event_manager/event_manager.gd")

var plugin:EditorPlugin
var node:EvManager

func list_timelines() -> void:
	clear()
	if !is_instance_valid(node):
		disabled = true
		return
	
	disabled = false
	for timeline_name in node.get_timeline_list():
		add_item(timeline_name)
	
