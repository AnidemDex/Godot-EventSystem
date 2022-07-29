tool
extends "godot_plugin.gd"

const TimelineEditor = preload("nodes/editor/timeline_editor.gd")
const EventManagerClass = preload("nodes/event_manager/event_manager.gd")
const EventClass = preload("resources/event_class/event_class.gd")
const TimelineClass = preload("resources/timeline_class/timeline_class.gd")

var timeline_editor:TimelineEditor
var timeline_dock_button:ToolButton

func _enter_tree():
	var inspector:EditorInspectorPlugin = load("res://addons/event_system_plugin/core/event_inspector.gd").new()
	register_editor_plugin(inspector)
	
	show_plugin_version_button()
	
	timeline_editor.connect("inspection_requested", self, "_on_TimelineEditor_inspect")
	timeline_dock_button = add_control_to_bottom_panel(timeline_editor, "TimelineEditor")
	timeline_dock_button.call_deferred("hide")
	
	var main_panel:PanelContainer = load("res://addons/event_system_plugin/nodes/editor/welcome/main_panel.tscn").instance()
	main_panel.set("repository", get_plugin_repository())
	main_panel.set("docs", get_plugin_docs_url())
	main_panel.set("version", get_plugin_version())
	get_plugin_welcome_node().get_tab_by_idx(0).add_child(main_panel)


func _enable_plugin():
	show_welcome_node()


func _handles(object: Object) -> bool:
	if object is Script:
		return false
	
	if object.get_class() == "ScriptEditorDebuggerInspectedObject":
		return false
	
	
	if object as EventManagerClass != null:
		return true
	
	if object as TimelineClass != null:
		return true
	
	return false


func _edit(object: Object) -> void:
		timeline_editor.set_undo_redo(get_undo_redo())
		timeline_editor.edit(object)


func _make_visible(visible: bool) -> void:
	if visible:
		timeline_dock_button.show()
		make_bottom_panel_item_visible(timeline_editor)
		timeline_editor.set_process_input(true)
	else:
		if timeline_dock_button.is_visible_in_tree():
			hide_bottom_panel()
		timeline_dock_button.hide()
		timeline_editor.set_process_input(false)


func _scene_change(scene_root:Node) -> void:
	pass


func _on_TimelineEditor_inspect(resource:Resource) -> void:
	get_editor_interface().inspect_object(resource, "", true)


func _init() -> void:
	timeline_editor = TimelineEditor.new()
	register_plugin_node(timeline_editor)
	
	connect("scene_changed", self, "_scene_change")
