tool
extends EditorPlugin

const PLUGIN_NAME = "EventSystem"
const _TimelineEditor = preload("res://addons/event_system_plugin/nodes/editor/timeline_editor/event_timeline_editor.gd")
const _EventManager = preload("res://addons/event_system_plugin/nodes/event_manager/event_manager.gd")
const _Timeline = preload("res://addons/event_system_plugin/resources/timeline_class/timeline_class.gd")
const _Event = preload("res://addons/event_system_plugin/resources/event_class/event_class.gd")

var _timeline_editor_scene:PackedScene = load("res://addons/event_system_plugin/nodes/editor/timeline_editor/event_timeline_editor.tscn") as PackedScene
var _registered_events:Resource = load("res://addons/event_system_plugin/resources/registered_events/registered_events.tres")
var _welcome_scene:PackedScene = load("res://addons/event_system_plugin/nodes/editor/welcome/hi.tscn")

var _timeline_editor:_TimelineEditor
var _dock_button:ToolButton
var _version_button:BaseButton

var _plugin_data:ConfigFile = ConfigFile.new()

var event_inspector:EditorInspectorPlugin


func _init() -> void:
	name = PLUGIN_NAME.capitalize()
	_plugin_data.load("res://addons/event_system_plugin/plugin.cfg")

func get_class(): return PLUGIN_NAME


func _enter_tree() -> void:
	_timeline_editor = _timeline_editor_scene.instance()
	_timeline_editor._UndoRedo = get_undo_redo()
	_timeline_editor._PluginScript = self
	_timeline_editor.connect("ready", _timeline_editor, "fake_ready")
	_timeline_editor.connect("event_selected", self, "_on_TimelineEditor_event_selected")
	connect("tree_exiting", _timeline_editor, "queue_free")
	
	_dock_button = add_control_to_bottom_panel(_timeline_editor, "TimelineEditor")
	_dock_button.visible = false
	_add_version_button()
	
	event_inspector = load("res://addons/event_system_plugin/core/event_inspector.gd").new()
	add_inspector_plugin(event_inspector)


func enable_plugin() -> void:
	_show_welcome()


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


func save_external_data() -> void:
	if is_instance_valid(_timeline_editor):
		_timeline_editor.call_deferred("_update_values")


func _exit_tree() -> void:
	if is_instance_valid(_timeline_editor):
		remove_control_from_bottom_panel(_timeline_editor)
		_timeline_editor.queue_free()
	remove_inspector_plugin(event_inspector)


func _show_welcome() -> void:
	var _popup:Popup = _welcome_scene.instance() as Popup
	_popup.connect("ready", _popup, "popup_centered_ratio", [0.4])
	_popup.connect("popup_hide", _popup, "queue_free")
	_popup.connect("hide", _popup, "queue_free")
	get_editor_interface().get_base_control().add_child(_popup)


func _add_version_button() -> void:
	var _v = {"version":get_plugin_version()}
	_version_button = ToolButton.new()
	connect("tree_exiting", _version_button, "free")
	_version_button.text = "ES:[{version}]".format(_v)
	_version_button.hint_tooltip = "EventSystem version {version}".format(_v)
	var _new_color = _version_button.get_color("font_color")
	_new_color.a = 0.6
	_version_button.add_color_override("font_color", _new_color)
	_version_button.size_flags_horizontal = Control.SIZE_SHRINK_END|Control.SIZE_EXPAND
	_version_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_dock_button.get_parent().add_child(_version_button)
	


func get_plugin_version() -> String:
	var _version = _plugin_data.get_value("plugin","version", "0")
	return _version

var _last_selected_node:Control = null
func _on_TimelineEditor_event_selected(event:_Event) -> void:
	var _focus_owner = _timeline_editor.get_focus_owner()
	
	if _last_selected_node == _focus_owner:
		return

	_last_selected_node = _focus_owner
	get_editor_interface().inspect_object(event, "", true)
	_focus_owner.grab_focus()


func _on_RegisteredEvents_changed() -> void:
	print("Events changed")


func _on_TimelineEditor_preview_edit_pressed(resource) -> void:
	get_editor_interface().edit_resource(resource)
