tool
extends VBoxContainer

const TimelineDisplayer = preload("res://addons/event_system_plugin/nodes/editor/timeline_displayer.gd")
const EventNode = preload("res://addons/event_system_plugin/nodes/editor/event_node/event_node.gd")
const CategoryManager = preload("res://addons/event_system_plugin/nodes/editor/category_manager.gd")
const EventClass = preload("res://addons/event_system_plugin/resources/event_class/event_class.gd")
const TimelineClass = preload("res://addons/event_system_plugin/resources/timeline_class/timeline_class.gd")
const EventMenu = preload("res://addons/event_system_plugin/nodes/editor/event_node/event_popup_menu.gd")
const TimelineList = preload("res://addons/event_system_plugin/nodes/editor/timeline_list.gd")
const EventManagerClass = preload("res://addons/event_system_plugin/nodes/event_manager/event_manager.gd")

enum {
	TOOL_NEW_TIMELINE,
	TOOL_DUPLICATE_TIMELINE,
	TOOL_RENAME_TIMELINE,
	TOOL_REMOVE_TIMELINE,
	TOOL_EDIT_RESOURCE
}

signal inspection_requested(resource)

var shortcuts = load("res://addons/event_system_plugin/core/shortcuts.gd")

var timeline_displayer:TimelineDisplayer
var last_selected_event_node:EventNode
var is_moving_event:bool = false

var _sc:ScrollContainer
var _event_menu:EventMenu
var _edited_sequence:TimelineClass
var _category_manager:CategoryManager
var _timeline_list:TimelineList
var _timeline_tools:MenuButton
var _error_dialog:AcceptDialog
var _error_label:Label
var _name_dialog:ConfirmationDialog
var _new_name_label:Label
var _new_name_edit:LineEdit
var _remove_dialog:ConfirmationDialog
var _remove_label:Label
var _info_label:Label

var _renaming := false

var _edited_node:EventManagerClass

var __undo_redo:UndoRedo # Do not use thid directly, get its reference with _get_undo_redo
var __group:ButtonGroup

func set_undo_redo(value:UndoRedo) -> void:
	# Sets UndoRedo, but this object can leave leaked isntances so make sure to set it
	# with an external reference (aka Editor's UndoRedo).
	# To internal use of UndoRedo use _get_undo_redo instead.
	__undo_redo = value

func edit(object:Object) -> void:
	if object is TimelineClass:
		_info_label.show()
		_info_label.text = "You're editing a single timeline. Some editor tools may not be enabled."
		
		_edited_node = null
		
		_timeline_list.node = null
		_timeline_list.list_timelines()
		_timeline_list.add_item(object.resource_name)
		_timeline_list.disabled = true
		
		_timeline_tools.disabled = true
		
		edit_timeline(object)
	
	if object is EventManagerClass:
		_info_label.hide()
		_timeline_list.disabled = false
		_timeline_tools.disabled = false
		edit_node(object)


func edit_node(node:EventManagerClass) -> void:
	_edited_node = node
	_timeline_list.node = _edited_node
	_timeline_list.list_timelines()
	if _edited_node:
		if _get_current() == "":
			edit_timeline(null)
			return
		
		edit_timeline(_edited_node.get_timeline(_get_current()))


func edit_timeline(sequence) -> void:
	_disconnect_edited_sequence_signals()
	
	_edited_sequence = sequence
	timeline_displayer.remove_all_displayed_events()
	if sequence:
		timeline_displayer.load_timeline(sequence)
	
	_connect_edited_sequence_signals()


func edit_timeline_by_name(timeline_name:String) -> void:
	for idx in _timeline_list.get_item_count():
		var item_name = _timeline_list.get_item_text(idx)
		if item_name == timeline_name:
			_timeline_list.select(idx)
	
	edit_timeline(_edited_node.get_timeline(_get_current()))


func reload() -> void:
	timeline_displayer.call_deferred("load_timeline", _edited_sequence)


func remove_event(event:EventClass, from_resource:TimelineClass) -> void:
	if event == null or from_resource == null:
		return
	
	var _UndoRedo:UndoRedo = _get_undo_redo()
	
	var parent_event_ref:WeakRef = event.event_subevent_from
	var parent_event:EventClass
	var old_value:int = 0
	var new_value:int = 0
	if parent_event_ref:
		parent_event = parent_event_ref.get_ref() as EventClass
		if parent_event:
			old_value = parent_event.event_subevents_quantity
			new_value = max(0, old_value-1)
	
	var event_idx:int = from_resource.get_event_idx(event)
	_UndoRedo.create_action("Remove event from timeline")
	_UndoRedo.add_do_method(from_resource, "erase_event", event)
	_UndoRedo.add_undo_method(from_resource, "insert_event", event, event_idx)
	
	if parent_event:
		_UndoRedo.add_do_property(parent_event, "event_subevents_quantity", new_value)
		_UndoRedo.add_undo_property(parent_event, "event_subevents_quantity", old_value)
	
	_UndoRedo.commit_action()


func add_event(event:EventClass, at_position:int=-1, from_resource:Resource=_edited_sequence, as_subevent_of:EventClass=null) -> void:
	if not from_resource:
		return
	
	var _UndoRedo:UndoRedo = _get_undo_redo()
	
	var parent_event:EventClass = as_subevent_of
	var old_value:int = 0
	var new_value:int = 0
	if parent_event:
		old_value = parent_event.event_subevents_quantity
		new_value = old_value+1
	
	_UndoRedo.create_action("Add event %s"%event.event_name)
	if at_position < 0:
		_UndoRedo.add_do_method(from_resource, "add_event", event)
	else:
		_UndoRedo.add_do_method(from_resource, "insert_event", event, at_position)
	
	_UndoRedo.add_undo_method(from_resource, "erase_event", event)
	
	if parent_event:
		_UndoRedo.add_do_property(parent_event, "event_subevents_quantity", new_value)
		_UndoRedo.add_undo_property(parent_event, "event_subevents_quantity", old_value)
	
	_UndoRedo.commit_action()


func move_event(event:EventClass, to:int, from_resource:TimelineClass=_edited_sequence, as_subevent_of:EventClass=null) -> void:
	if not from_resource:
		return
	
	var old_position:int = from_resource.get_event_idx(event)
	
	var _UndoRedo:UndoRedo = _get_undo_redo()
	
	_UndoRedo.create_action("Move event %s"%event.event_name)
	
	var old_parent:EventClass
	var new_parent:EventClass = as_subevent_of
	
	if event.event_subevent_from:
		old_parent = event.event_subevent_from.get_ref() as EventClass
	
	var old_value:int = 0
	var new_value:int = 0
	
	if !from_resource.event_is_subevent_of(event, new_parent):
		if old_parent:
			old_value = old_parent.event_subevents_quantity
			new_value = max(0, old_value-1)
			_UndoRedo.add_do_property(old_parent, "event_subevents_quantity", new_value)
			_UndoRedo.add_undo_property(old_parent, "event_subevents_quantity", old_value)
		
		if new_parent:
			old_value = new_parent.event_subevents_quantity
			new_value = old_value+1
			_UndoRedo.add_do_property(new_parent, "event_subevents_quantity", new_value)
			_UndoRedo.add_undo_property(new_parent, "event_subevents_quantity", old_value)
	
	if to < 0:
		if old_parent:
			old_value = old_parent.event_subevents_quantity
			new_value = max(0, old_value-1)
			_UndoRedo.add_do_property(old_parent, "event_subevents_quantity", new_value)
			_UndoRedo.add_undo_property(old_parent, "event_subevents_quantity", old_value)
	
	event.event_indent_level = 0
	
	_UndoRedo.add_do_method(from_resource, "move_event", event, to)
	_UndoRedo.add_undo_method(from_resource, "move_event", event, old_position)
	
	_UndoRedo.commit_action()


func get_drag_data_fw(position, node):
	if node is EventNode:
		var event:EventClass = node.get("event")
		var timeline:TimelineClass = node.get("timeline")
		is_moving_event = true
		
		if not event:
			return null
			
		var _node = node.duplicate(0)
		
		_node.rect_size = Vector2.ZERO
		set_drag_preview(_node)
		var data = {}
		data["event"] = event
		
		return data


var _separator_node:EventNode
var _idx_hint:int = -1
var _last_node:Node
func can_drop_data_fw(position: Vector2, data, node:Control) -> bool:
	var event_data:EventClass
	
	if typeof(data) in [TYPE_OBJECT, TYPE_DICTIONARY]:
		event_data = data.get("event")
		if event_data == null:
			return false
	else:
		return false
	
#	if !is_instance_valid(_separator_node):
#		_generate_separator_node()
#	_separator_node.event = node.get("event") as EventClass
#	_separator_node.update_values()
#
#	if node is EventNode:
#		var node_rect:Rect2 = node.get_rect()
#		var node_event = node.get("event")
#
#		var pos = node.get_index()
#		if position.y > node_rect.size.y/2:
#			pos = node.get_index()+1
#		timeline_displayer.move_child(_separator_node, pos)
	
	_last_node = node
#	return node is TimelineDisplayer and event_data is EventClass
	return event_data is EventClass


func drop_data_fw(position: Vector2, data, node) -> void:
	var event_data:EventClass = data.get("event")
	var subevent_of = null
	
	if node is EventNode:
		if event_data == node.event:
			return
		
		if node != _separator_node:
			var node_rect:Rect2 = node.get_rect()
			var node_event = node.get("event")
			
			_idx_hint = _edited_sequence.get_event_idx(node.event)
			if position.y > node_rect.size.y/2:
				_idx_hint = _edited_sequence.get_event_idx(node.event)+1
				
				if node.event.event_uses_subevents:
					subevent_of = node.event
				
				elif node.event.event_subevent_from:
					subevent_of = node.event.event_subevent_from.get_ref()
				
				if event_data.event_subevent_from:
					pass
		
		event_data.event_indent_level = node.event.event_indent_level
	
	if node is TimelineDisplayer:
		_idx_hint = -1
		event_data.event_indent_level = 0
		event_data.event_subevent_from = null
	
	if !is_moving_event:
		add_event(event_data, _idx_hint, _edited_sequence, subevent_of)
	else:
		move_event(event_data, _idx_hint, _edited_sequence, subevent_of)
	
	_idx_hint = -1


func _generate_separator_node() -> void:
	_separator_node = EventNode.new()
	_separator_node.propagate_call("set", ["focus_mode", Control.FOCUS_NONE])
	_separator_node.propagate_call("set", ["mouse_filter", Control.MOUSE_FILTER_PASS])
	_separator_node.modulate.a = 0.5
	_separator_node.modulate = _separator_node.modulate.darkened(0.2)
	connect("tree_exited", _separator_node, "free")
#	_separator_node.set_drag_forwarding(self)
	timeline_displayer.add_child(_separator_node)


func _get_undo_redo() -> UndoRedo:
	if not is_instance_valid(__undo_redo):
		__undo_redo = UndoRedo.new()
		connect("tree_exiting", __undo_redo, "free")
	return __undo_redo


func _disconnect_edited_sequence_signals() -> void:
	if _edited_sequence:
		if _edited_sequence.is_connected("changed", self, "reload"):
			_edited_sequence.disconnect("changed",self,"reload")


func _connect_edited_sequence_signals() -> void:
	if _edited_sequence:
		if not _edited_sequence.is_connected("changed",self,"reload"):
			_edited_sequence.connect("changed",self,"reload", [], CONNECT_DEFERRED)


func _timeline_selected(_index:int) -> void:
	var current := _get_current()
	
	if current != "":
		var timeline = _edited_node.get_timeline(current)
		edit_timeline(timeline)


func _timeline_tools_menu(option:int):
	match option:
		TOOL_NEW_TIMELINE:
			_timeline_new()
		
		TOOL_DUPLICATE_TIMELINE:
			_timeline_duplicate()
			
		TOOL_RENAME_TIMELINE:
			_timeline_rename()
			
		TOOL_REMOVE_TIMELINE:
			_timeline_remove()
		
		TOOL_EDIT_RESOURCE:
			_timeline_edit_resource()


func _timeline_new() -> void:
	_renaming = false
	_name_dialog.window_title = "New Timeline"
	_new_name_edit.placeholder_text = ""
	_new_name_edit.text = ""
	_name_dialog.popup_centered()


func _timeline_duplicate() -> void:
	var _timeline:TimelineClass = _edited_node.get_timeline(_get_current())
	if _timeline == null:
		return
	
	# For some reason, duplicate(true) removes the script
	var new_timeline = _timeline.duplicate()
	
	var events = new_timeline.get_events()
	var new_events = []
	for event in events:
		new_events.append(event.duplicate())
	new_timeline.set_events(new_events)
	
	var new_name := _get_current() + " ({idx})"
	var idx = 2
	while _edited_node.has_timeline(new_name.format({"idx":idx})):
		idx += 1
	
	_edited_node.add_timeline(new_name.format({"idx":idx}), new_timeline)
	edit_node(_edited_node)

func _timeline_rename() -> void:
	_renaming = true
	_name_dialog.window_title = "Rename Timeline"
	_new_name_edit.placeholder_text = _get_current()
	_new_name_edit.text = _get_current()
	_name_dialog.popup_centered()


func _timeline_remove() -> void:
	_remove_label.text = "Removing '%s' timeline. Are you sure?"%_get_current()
	_remove_dialog.popup_centered()


func _timeline_edit_resource() -> void:
	if !Engine.editor_hint:
		print("Tried to edit the resource, but you're not in the editor!")
		return
	emit_signal("inspection_requested", _edited_node.get_timeline(_get_current()))


func _get_current() -> String:
	var current:String = ""
	var selected_id:int = _timeline_list.get_selected_id()
	
	if selected_id >= 0 && selected_id < _timeline_list.get_item_count():
		current = _timeline_list.get_item_text(selected_id)
		
	return current


func _input(event: InputEvent) -> void:
	var event_node = last_selected_event_node
	var focus_owner = get_focus_owner()
	
	if not is_instance_valid(event_node):
		return
	
	if is_instance_valid(focus_owner):
		if not event_node.is_a_parent_of(focus_owner):
			return
	
	var _event = last_selected_event_node.get("event")
	
	var duplicate_shortcut = shortcuts.get_shortcut("duplicate")
	if event.shortcut_match(duplicate_shortcut.shortcut):
		if _event and event.is_pressed():
			timeline_displayer.remove_all_displayed_events()
			var position:int = _edited_sequence.get_events().find(_event)
			add_event(_event.duplicate(), position+1, event_node.timeline)
		event_node.accept_event()
	
	var delete_shortcut = shortcuts.get_shortcut("delete")
	if event.shortcut_match(delete_shortcut.shortcut):
		if _event:
			timeline_displayer.remove_all_displayed_events()
			remove_event(_event, event_node.timeline)
		event_node.accept_event()


func _on_EventButton_selected(button) -> void:
	last_selected_event_node = button.get_meta("event_node")
	emit_signal("inspection_requested", last_selected_event_node.event)


func _on_EventNode_gui_input(event: InputEvent, event_node:EventNode) -> void:
	var _event:EventClass = event_node.event
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			if _event:
				_event_menu.used_event = _event
				_event_menu.popup(Rect2(get_global_mouse_position()+Vector2(1,1), _event_menu.rect_size))
			event_node.event_button.pressed = true
			event_node.accept_event()


func _on_TimelineDisplayer_event_node_added(event_node:Control) -> void:
	if not event_node.is_connected("gui_input", self, "_on_EventNode_gui_input"):
		event_node.connect("gui_input", self, "_on_EventNode_gui_input", [event_node])
	
	event_node.set_drag_forwarding(self)
	event_node.set_button_group(__group)


func _on_EventMenu_index_pressed(idx:int) -> void:
	var _used_event:EventClass = _event_menu.used_event as EventClass
	
	if _used_event == null:
		return
	
	# I'm not gonna lost my time recycling nodes tbh
#	timeline_displayer.remove_all_displayed_events()
	
	match idx:
		EventMenu.ItemType.EDIT:
			emit_signal("inspection_requested", _used_event)
		
		EventMenu.ItemType.DUPLICATE:
			var position:int = _edited_sequence.get_events().find(_used_event)
			add_event(_used_event.duplicate(), position+1)
			
		EventMenu.ItemType.REMOVE:
			remove_event(_used_event, _edited_sequence)


func _on_CategoryManager_button_pressed(button:Button, event_script:Script) -> void:
	var idx := -1
	var timeline := _edited_sequence
	if is_instance_valid(last_selected_event_node):
		idx = last_selected_event_node.idx+1
		timeline = last_selected_event_node.timeline
	if not timeline:
		timeline = _edited_sequence
		idx = -1
	add_event(event_script.new(), idx, timeline)


func _on_name_dialog_confirmed() -> void:
	if !is_instance_valid(_edited_node):
		return
	
	var new_name:String = _new_name_edit.text
	
	if new_name == "":
		_error_label.text = "Timeline label can't be empty"
		_error_dialog.popup_centered()
		return
	
	if new_name == "[None]":
		_error_label.text = "Invalid name!"
		_error_dialog.popup_centered()
		return
	
	if _renaming:
		_renaming = false
		
		if new_name == _get_current():
			_name_dialog.hide()
			return
		
		_edited_node.rename_timeline(_get_current(), new_name)
	
	else:
		if _edited_node.has_timeline(new_name):
			_error_label.text = "Timeline '%s' already exist"%new_name
			_error_dialog.popup_centered()
			return
		
		var res:TimelineClass = TimelineClass.new()
		res.resource_name = new_name
		_edited_node.add_timeline(new_name, res)
	
	edit_node(_edited_node)
	edit_timeline_by_name(new_name)
	
	if _get_undo_redo() != null:
		_get_undo_redo().clear_history()
	
	_name_dialog.hide()


func _on_remove_dialog_confirmed() -> void:
	if !is_instance_valid(_edited_node):
		return
	
	_edited_node.remove_timeline(_get_current())
	edit_node(_edited_node)

func _init() -> void:
	__group = ButtonGroup.new()
	__group.connect("pressed", self, "_on_EventButton_selected")
	add_constant_override("separation", 2)
	theme = load("res://addons/event_system_plugin/assets/themes/timeline_editor.tres") as Theme
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	_sc = ScrollContainer.new()
	_sc.follow_focus = true
	_sc.size_flags_horizontal = SIZE_EXPAND_FILL
	_sc.size_flags_vertical = SIZE_EXPAND_FILL
	_sc.mouse_filter = Control.MOUSE_FILTER_PASS
	var scale := 1.0
	
	if Engine.editor_hint:
		var plugin:EditorPlugin = EditorPlugin.new()
		scale = float(plugin.get_editor_interface().get_editor_scale())
		plugin.free()
	
	_sc.rect_min_size = Vector2(0, 180) * scale
	
	var _dummy_panel := PanelContainer.new()
	_dummy_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	_dummy_panel.size_flags_vertical = SIZE_EXPAND_FILL
	_dummy_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_dummy_panel.focus_mode = Control.FOCUS_CLICK
	_sc.add_child(_dummy_panel)
	
	var timeline_drawer = load("res://addons/event_system_plugin/nodes/editor/timeline_drawer.gd").new()
	timeline_drawer.focus_mode = Control.FOCUS_NONE
	timeline_drawer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dummy_panel.add_child(timeline_drawer)
	
	timeline_displayer = TimelineDisplayer.new()
	timeline_displayer.connect("event_node_added", self, "_on_TimelineDisplayer_event_node_added")
	_dummy_panel.add_child(timeline_displayer)
	timeline_drawer.timeline_displayer = timeline_displayer
	timeline_displayer.set_drag_forwarding(self)
	
	_category_manager = CategoryManager.new()
	_category_manager.connect("toolbar_button_pressed", self, "_on_CategoryManager_button_pressed")
	
	_event_menu = EventMenu.new()
	_event_menu.connect("index_pressed", self, "_on_EventMenu_index_pressed")
	_event_menu.connect("hide", _event_menu, "set", ["used_event", null])
	
	var _hs := HSplitContainer.new()
	_hs.size_flags_horizontal = SIZE_EXPAND_FILL
	_hs.size_flags_vertical = SIZE_EXPAND_FILL
	
	_hs.add_child(_category_manager)
	
	var _vb = VBoxContainer.new()
	_vb.add_constant_override("separation", 4)
	
	var _toolbar := HBoxContainer.new()
	_timeline_tools = MenuButton.new()
	_timeline_tools.text = "Timeline"
	_timeline_tools.flat = false
	
	_timeline_tools.get_popup().add_item("New", TOOL_NEW_TIMELINE)
	_timeline_tools.get_popup().add_separator()
	_timeline_tools.get_popup().add_item("Duplicate", TOOL_DUPLICATE_TIMELINE)
	_timeline_tools.get_popup().add_separator()
	_timeline_tools.get_popup().add_item("Rename...", TOOL_RENAME_TIMELINE)
	_timeline_tools.get_popup().add_item("Open in Inspector", TOOL_EDIT_RESOURCE)
	_timeline_tools.get_popup().add_separator()
	_timeline_tools.get_popup().add_item("Remove", TOOL_REMOVE_TIMELINE)
	
	_timeline_list = TimelineList.new()
	_timeline_list.size_flags_horizontal = SIZE_EXPAND_FILL
	
	_name_dialog = ConfirmationDialog.new()
	_name_dialog.window_title = "Create New Timeline"
	_name_dialog.dialog_hide_on_ok = false
	add_child(_name_dialog)
	
	var vb = VBoxContainer.new()
	_name_dialog.add_child(vb)
	
	_new_name_label = Label.new()
	_new_name_label.text = "Timeline name:"
	vb.add_child(_new_name_label)
	
	_new_name_edit = LineEdit.new()
	_new_name_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	vb.add_child(_new_name_edit)
	_name_dialog.register_text_enter(_new_name_edit)
	
	_error_dialog = AcceptDialog.new()
	_error_dialog.window_title = "Error!"
	add_child(_error_dialog)
	
	_error_label = Label.new()
	_error_dialog.add_child(_error_label)
	
	_remove_dialog = ConfirmationDialog.new()
	add_child(_remove_dialog)
	
	_remove_label = Label.new()
	_remove_label.text = "Are you sure?"
	_remove_dialog.add_child(_remove_label)
	
	_info_label = Label.new()
	_info_label.align = Label.ALIGN_CENTER
	_info_label.visible = false
	
	_toolbar.add_child(_timeline_tools)
	_toolbar.add_child(_timeline_list)
	_vb.add_child(_info_label)
	_vb.add_child(_toolbar)
	_vb.add_child(_sc)
	
	_hs.add_child(_vb)
	
	add_child(_hs)
	add_child(_event_menu)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE:
			_timeline_list.connect("item_selected", self, "_timeline_selected")
			_timeline_tools.get_popup().connect("id_pressed", self, "_timeline_tools_menu")
			_name_dialog.connect("confirmed", self, "_on_name_dialog_confirmed")
			_remove_dialog.connect("confirmed", self, "_on_remove_dialog_confirmed")
		
		NOTIFICATION_DRAG_END:
			if is_instance_valid(_separator_node):
				_separator_node.queue_free()
			
			if is_moving_event:
				is_moving_event = false
		
		NOTIFICATION_THEME_CHANGED:
			# For some reason this is called _before_ init (what?!)
			if !is_inside_tree():
				return
			_sc.add_stylebox_override("bg",get_stylebox("bg", "Tree"))
			_timeline_tools.add_stylebox_override("normal", get_stylebox("normal", "Button"))
			
			var menu:PopupMenu = _timeline_tools.get_popup()
			menu.set_item_icon(menu.get_item_index(TOOL_NEW_TIMELINE), get_icon("New", "EditorIcons"))
			menu.set_item_icon(menu.get_item_index(TOOL_DUPLICATE_TIMELINE), get_icon("Duplicate", "EditorIcons"))
			menu.set_item_icon(menu.get_item_index(TOOL_EDIT_RESOURCE), get_icon("Edit", "EditorIcons"))
			menu.set_item_icon(menu.get_item_index(TOOL_REMOVE_TIMELINE), get_icon("Remove", "EditorIcons"))
			menu.set_item_icon(menu.get_item_index(TOOL_RENAME_TIMELINE), get_icon("Rename", "EditorIcons"))
			
