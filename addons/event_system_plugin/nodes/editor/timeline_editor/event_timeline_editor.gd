tool
extends Container

signal event_selected(event)

const _CategoryManager = preload("res://addons/event_system_plugin/nodes/editor/category_manager/category_manager.gd")
const _TimelineDisplayer = preload("res://addons/event_system_plugin/nodes/editor/timeline_editor/timeline_displayer.gd")

export(NodePath) var ResourceNamePath:NodePath
export(NodePath) var CategoryManagerPath:NodePath

export(NodePath) var EventContainerPath:NodePath

var _UndoRedo:UndoRedo
var _edited_resource:Timeline
var _registered_events:Array = load("res://addons/event_system_plugin/resources/registered_events/registered_events.tres")["events"]
var _separator_node:Control
var _last_focused_event_node:Control

onready var _name_node:Label = get_node(ResourceNamePath) as Label
onready var _category_manager:_CategoryManager = get_node(CategoryManagerPath) as _CategoryManager
onready var _timeline_displayer:_TimelineDisplayer = get_node(EventContainerPath) as _TimelineDisplayer


func fake_ready() -> void:
	_timeline_displayer.set_drag_forwarding(self)
	get_tree().root.connect("gui_focus_changed", self, "_on_global_focus_changed", [], CONNECT_DEFERRED)


func edit_resource(resource) -> void:
	if _edited_resource == resource:
		_timeline_displayer.reload()
		return
	
	if _edited_resource:
		if _edited_resource.is_connected("changed", _timeline_displayer, "reload"):
			_edited_resource.disconnect("changed", _timeline_displayer, "reload")
	
	_edited_resource = resource
	
	_update_values()


func _update_values() -> void:
	if _edited_resource == null:
		push_error("No resource to edit")
		_timeline_displayer.call("_unload_events")
		return
	
	_connect_resource_signals()
	_update_displayed_name()
	_generate_event_buttons()
	_update_timeline_displayer()


func _connect_resource_signals() -> void:
	if not _edited_resource.is_connected("changed", _timeline_displayer, "reload"):
		_edited_resource.connect("changed", _timeline_displayer, "reload")


func _update_displayed_name() -> void:
	var _name:String = _edited_resource.resource_name
	
	if _name == "":
		_name = _edited_resource.resource_path.get_file()
	
	_name_node.text = _name


func _generate_event_buttons() -> void:
	for event in _registered_events:
		_category_manager.add_event(event)


func _generate_separator_node() -> void:
	_separator_node = load("res://addons/event_system_plugin/nodes/editor/event_node/event_node.tscn").instance()
	_separator_node.set_drag_forwarding(self)
	_separator_node.modulate.a = 0.5
	_separator_node.modulate = _separator_node.modulate.darkened(0.2)


func _update_timeline_displayer() -> void:
	_timeline_displayer.load_timeline(_edited_resource)


func _add_event(event:Event, at_position:int=-1) -> void:
	_UndoRedo.create_action("Add event to timeline")
	_UndoRedo.add_do_method(_edited_resource, "add_event", event, at_position)
	_UndoRedo.add_undo_method(_edited_resource, "erase_event", event)
	_UndoRedo.commit_action()


func _remove_event(event:Event) -> void:
	var event_idx:int = _edited_resource.get_events().find(event)
	_UndoRedo.create_action("Remove event from timeline")
	_UndoRedo.add_do_method(_edited_resource, "erase_event", event)
	_UndoRedo.add_undo_method(_edited_resource, "add_event", event, event_idx)
	_UndoRedo.commit_action()


func _on_CategoryManager_event_pressed(event:Event) -> void:
	var idx:int = -1
	if is_instance_valid(_last_focused_event_node):
		idx = int(_last_focused_event_node.get("event_index"))+1
	
	_add_event(event, idx)


func _on_TimelineDisplayer_event_node_added(event_node:Control) -> void:
	event_node.set_drag_forwarding(self)
	event_node.connect("gui_input", self, "_on_EventNode_gui_input", [event_node])


func _on_global_focus_changed(control:Control) -> void:
	if _category_manager.is_a_parent_of(control):
		return
	
	if control is _TimelineDisplayer._EventNode:
		_last_focused_event_node = control
		emit_signal("event_selected", control.get("event"))
		return
	
	_last_focused_event_node = null


func _on_EventNode_gui_input(event: InputEvent, event_node) -> void:
	if event is InputEventKey:
		if event.scancode == KEY_DELETE:
			var _event = event_node.get("event")
			_remove_event(_event)
			accept_event()

###########
# Drag&Drop(TM)
###########

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_BEGIN:
			_on_drag_begin()
		NOTIFICATION_DRAG_END:
			_on_drag_end()


func _on_drag_begin() -> void:
	var drag_data = get_tree().root.gui_get_drag_data()
	
	if not drag_data:
		return
	
	if not(drag_data is Event):
		return
	
	_remove_event(drag_data)
	
	if not is_instance_valid(_separator_node):
		_generate_separator_node()


func _on_drag_end() -> void:
	if is_instance_valid(_separator_node):
		_separator_node.queue_free()


func can_drop_data_fw(position: Vector2, data, node:Control) -> bool:
	if not(data is Event):
		return false
	
	if node == _timeline_displayer:
		return true
	
	if node == _separator_node:
		return true
	
	var node_rect:Rect2 = node.get_rect()
	var node_idx:int = int(node.get("event_index"))
	
	_separator_node.set("event_index", node_idx)
	
	
	var _drop_index_hint:int = -1
	if position.y > node_rect.size.y/2:
		_drop_index_hint = node_idx+1
	else:
		_drop_index_hint = node_idx
	
	if not _timeline_displayer.is_a_parent_of(_separator_node):
		if _separator_node.is_inside_tree():
			_separator_node.get_parent().remove_child(_separator_node)
		_timeline_displayer.add_child(_separator_node)
	
	_separator_node.set("event", data)
	_separator_node.set("event_index", _drop_index_hint)
	_separator_node.call("_update_event_colors")
	_separator_node.call("_update_event_name")
	_separator_node.call("_update_event_index")
	
	_timeline_displayer.move_child(_separator_node, _drop_index_hint)
	
	return true


func drop_data_fw(position: Vector2, data, node) -> void:
	if node == _timeline_displayer and data is Event:
		_add_event(data)
		return
	
	var _position:int = _separator_node.event_index
	_add_event(data, _position)
