tool
extends "godot_plugin.gd"

const TimelineEditor = preload("nodes/editor/timeline_editor.gd")
const EventManagerClass = preload("nodes/event_manager/event_manager.gd")
const EventClass = preload("resources/event_class/event_class.gd")
const TimelineClass = preload("resources/timeline_class/timeline_class.gd")

var timeline_editor:TimelineEditor
var timeline_dock_button:ToolButton

func _enter_tree():
	show_plugin_version_button()
	
	timeline_editor = TimelineEditor.new()
	register_plugin_node(timeline_editor)
	timeline_dock_button = add_control_to_bottom_panel(timeline_editor, "TimelineEditor")
	timeline_dock_button.hide()
	
	connect("scene_changed", self, "_scene_change")


func _enable_plugin():
	show_welcome_node()


func _handles(object: Object) -> bool:
	if object is EventManagerClass:
		return true
	
	if object is EventClass:
		return true
	
	return false


func _edit(object: Object) -> void:
	timeline_editor.set_undo_redo(get_undo_redo())
	var timeline:Resource = object.get("timeline")
	if !timeline:
		return
	timeline_editor.edit_timeline(timeline)


func _make_visible(visible: bool) -> void:
	if visible:
		timeline_dock_button.show()
		make_bottom_panel_item_visible(timeline_editor)
	else:
		if timeline_dock_button.is_visible_in_tree():
			hide_bottom_panel()
		timeline_dock_button.hide()
