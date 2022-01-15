extends VBoxContainer

class EventMenu extends PopupMenu:
	enum ItemType {TITLE,EDIT,DUPLICATE,REMOVE}
	
	var used_event:Resource setget set_event
	var shortcuts = load("res://addons/event_system_plugin/core/shortcuts.gd")
	
	func _enter_tree() -> void:
		var remove_shortcut = shortcuts.get_shortcut("remove")
		var duplicate_shortcut = shortcuts.get_shortcut("duplicate")
		
		add_separator("{EventName}")
		
		add_icon_item(get_icon("Edit", "EditorIcons"), "Edit")
		
		add_shortcut(duplicate_shortcut)
		set_item_icon(ItemType.DUPLICATE, get_icon("ActionCopy", "EditorIcons"))
		set_item_text(ItemType.DUPLICATE, "Duplicate")
		
		add_shortcut(remove_shortcut)
		set_item_icon(ItemType.REMOVE, get_icon("Remove", "EditorIcons"))
		set_item_text(ItemType.REMOVE, "Remove")
	
	
	func set_title(title:String) -> void:
		set_item_text(0, title)
	
	
	func set_event(event:Resource) -> void:
		used_event = event
		var event_name:String = "{EventName}"
		if used_event:
			event_name = str(used_event.get("event_name"))
		set_title(event_name)


const SequenceDisplayer = preload("res://addons/event_system_plugin/nodes/editor/timeline_displayer.gd")
const EventNode = preload("res://addons/event_system_plugin/nodes/editor/event_node/event_node.gd")

var shortcuts = load("res://addons/event_system_plugin/core/shortcuts.gd")

var seq_displayer:SequenceDisplayer
var last_selected_event:Event

var _sc:ScrollContainer
var _event_menu:EventMenu
var _edited_sequence:Resource
var _info_label:Label

var __undo_redo:UndoRedo # Do not use thid directly, get its reference with _get_undo_redo

func set_undo_redo(value:UndoRedo) -> void:
	# Sets UndoRedo, but this object can leave leaked isntances so make sure to set it
	# with an external reference (aka Editor's UndoRedo).
	# To internal use of UndoRedo use _get_undo_redo instead.
	__undo_redo = value


func edit_sequence(sequence) -> void:
	_disconnect_edited_sequence_signals()
	
	_edited_sequence = sequence
	seq_displayer.remove_all_displayed_events()
	seq_displayer.load_timeline(sequence)
	update_info_label()
	
	_connect_edited_sequence_signals()


func reload() -> void:
	seq_displayer.call_deferred("load_timeline", _edited_sequence)
	update_info_label()


func update_info_label() -> void:
	var text := "Path: {0}|{1}"
	var args = ["[No resource]", "Open a sequence to start editing"]
	
	if _edited_sequence:
		args[0] = _edited_sequence.resource_path
		args[1] = _edited_sequence.resource_name
	
	_info_label.text = text.format(args)

func remove_event(event:Event) -> void:
	var _UndoRedo:UndoRedo = _get_undo_redo()
	
	var event_idx:int = _edited_sequence.get_events().find(event)
	_UndoRedo.create_action("Remove event from timeline")
	_UndoRedo.add_do_method(_edited_sequence, "erase_event", event)
	_UndoRedo.add_undo_method(_edited_sequence, "add_event", event, event_idx)
	_UndoRedo.commit_action()


func add_event(event:Event, at_position:int=-1) -> void:
	if not _edited_sequence:
		return
	
	var _UndoRedo:UndoRedo = _get_undo_redo()
	_UndoRedo.create_action("Add event %s"%event.event_name)
	_UndoRedo.add_do_method(_edited_sequence, "add_event", event, at_position)
	_UndoRedo.add_undo_method(_edited_sequence, "erase_event", event)
	_UndoRedo.commit_action()


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
			_edited_sequence.connect("changed",self,"reload")





func _on_EventNode_gui_input(event: InputEvent, event_node:EventNode) -> void:
	var _event:Event = event_node.event
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			if _event:
				_event_menu.used_event = _event
				_event_menu.popup(Rect2(get_local_mouse_position()+Vector2(1,1), _event_menu.rect_size))
			event_node.accept_event()
		
		if (event.button_index in [BUTTON_LEFT,BUTTON_RIGHT]) and event.pressed:
			if _event:
				last_selected_event = _event
	
	var duplicate_shortcut = shortcuts.get_shortcut("duplicate")
	if event.shortcut_match(duplicate_shortcut.shortcut):
		if _event and event.is_pressed():
			var position:int = _edited_sequence.get_events().find(_event)
			add_event(_event.duplicate(), position+1)
		event_node.accept_event()
	
	var delete_shortcut = shortcuts.get_shortcut("delete")
	if event.shortcut_match(delete_shortcut.shortcut):
		if _event:
			seq_displayer.remove_all_displayed_events()
			remove_event(_event)
		event_node.accept_event()


func _on_SequenceDisplayer_event_node_added(event_node:Control) -> void:
	if not event_node.is_connected("gui_input", self, "_on_EventNode_gui_input"):
		event_node.connect("gui_input", self, "_on_EventNode_gui_input", [event_node])


func _on_EventMenu_index_pressed(idx:int) -> void:
	var _used_event:Event = _event_menu.used_event as Event
	
	if _used_event == null:
		return
	
	match idx:
		EventMenu.ItemType.EDIT:
			pass
		EventMenu.ItemType.DUPLICATE:
			var position:int = _edited_sequence.get_events().find(_used_event)
			add_event(_used_event.duplicate(), position+1)
			
		EventMenu.ItemType.REMOVE:
			remove_event(_used_event)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	_info_label = Label.new()
	add_child(_info_label)
	
	_sc = ScrollContainer.new()
	_sc.follow_focus = true
	_sc.size_flags_horizontal = SIZE_EXPAND_FILL
	_sc.size_flags_vertical = SIZE_EXPAND_FILL
	_sc.mouse_filter = Control.MOUSE_FILTER_PASS
	_sc.add_stylebox_override("bg",get_stylebox("bg", "Tree"))
	
	seq_displayer = SequenceDisplayer.new()
	seq_displayer.connect("event_node_added", self, "_on_SequenceDisplayer_event_node_added")
	_sc.add_child(seq_displayer)
	add_child(_sc)
	
	_event_menu = EventMenu.new()
	_event_menu.connect("index_pressed", self, "_on_EventMenu_index_pressed")
	_event_menu.connect("hide", _event_menu, "set", ["used_event", null])
	add_child(_event_menu)
	
	connect("tree_exiting", _info_label, "queue_free")
	connect("tree_exiting", _sc, "queue_free")
