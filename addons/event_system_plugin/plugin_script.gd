tool
extends EditorPlugin

const PLUGIN_NAME = "EventSystem"
const _TimelineEditor = preload("res://addons/event_system_plugin/nodes/editor/timeline_editor/event_timeline_editor.gd")
const _EventManager = preload("res://addons/event_system_plugin/nodes/event_manager/event_manager.gd")
const _Timeline = preload("res://addons/event_system_plugin/resources/timeline_class/timeline_class.gd")
const _Event = preload("res://addons/event_system_plugin/resources/event_class/event_class.gd")

var _timeline_editor_scene:PackedScene = load("res://addons/event_system_plugin/nodes/editor/timeline_editor/event_timeline_editor.tscn") as PackedScene

var _timeline_editor:_TimelineEditor
var _dock_button:ToolButton

func _init() -> void:
	name = PLUGIN_NAME.capitalize()

func get_class(): return PLUGIN_NAME


func _enter_tree() -> void:
	_timeline_editor = _timeline_editor_scene.instance() as _TimelineEditor
	_timeline_editor._UndoRedo = get_undo_redo()
	_timeline_editor.connect("ready", _timeline_editor, "fake_ready")
	_timeline_editor.connect("event_selected", self, "_on_TimelineEditor_event_selected")
	_dock_button = add_control_to_bottom_panel(_timeline_editor, "TimelineEditor")
	_dock_button.visible = false


func enable_plugin() -> void:
	pass


func handles(object: Object) -> bool:
	if object is _Event:
		return true
	
	if object is _Timeline:
		return true
	
	return false


func edit(object: Object) -> void:
	if object is _Event:
		return
	
	_timeline_editor.edit_resource(object)


func make_visible(visible: bool) -> void:
	if is_instance_valid(_dock_button):
		_dock_button.visible = visible
		_dock_button.pressed = visible


func _exit_tree() -> void:
	if is_instance_valid(_timeline_editor):
		push_warning("Removing timeline editor")
		print_stack()
		remove_control_from_bottom_panel(_timeline_editor)
		_timeline_editor.queue_free()


func _on_TimelineEditor_event_selected(event:_Event) -> void:
	var _focused_node = _timeline_editor.get_focus_owner()
	var _focus_base = get_editor_interface().get_base_control().get_focus_owner()
	print("Focus owner before edit_resource: ", _focused_node)
	print("Focus owner in base before edit_resource: ", _focus_base)
	yield(get_tree(), "idle_frame")
#	get_editor_interface().edit_resource(event)
#	get_editor_interface().call_deferred("edit_resource", event)
	_focused_node = _timeline_editor.get_focus_owner()
	_focus_base = get_editor_interface().get_base_control().get_focus_owner()
	print("Focus owner after edit_resource: ", _focused_node)
	print("Focus owner in base after edit_resource: ", _focus_base)
