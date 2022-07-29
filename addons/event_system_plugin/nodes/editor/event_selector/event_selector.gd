tool
extends ConfirmationDialog

signal event_selected(event, timeline_path)

const TimelineDisplayer = preload("res://addons/event_system_plugin/nodes/editor/timeline_displayer.gd")
const TimelineList = preload("res://addons/event_system_plugin/nodes/editor/timeline_list.gd")
const TimelineClass = preload("res://addons/event_system_plugin/resources/timeline_class/timeline_class.gd")
const EvManager = preload("res://addons/event_system_plugin/nodes/event_manager/event_manager.gd")

export(NodePath) var displayer_path:NodePath
export(NodePath) var list_path:NodePath
onready var timeline_displayer:TimelineDisplayer = get_node(displayer_path) as TimelineDisplayer
onready var timeline_list:TimelineList = get_node(list_path) as TimelineList

var last_selected_item:Node = null
var timeline_name:String = ""
var button_group = ButtonGroup.new()
var edited_node:EvManager
var edited_timeline:TimelineClass
var event_summoner:Resource = null

func _notification(what):
	match what:
		NOTIFICATION_POPUP_HIDE:
			if not visible:
				set_deferred("timeline_name", "")
				set_deferred("used_timeline", null)
	
		NOTIFICATION_POST_POPUP:
			if Engine.editor_hint:
				edited_node = Engine.get_meta("EventSystem").timeline_editor._edited_node
				edited_timeline = Engine.get_meta("EventSystem").timeline_editor._edited_sequence
			
			timeline_list.node = edited_node
			timeline_list.list_timelines()
			build_timeline(edited_timeline)
		
		NOTIFICATION_POST_ENTER_TREE:
			theme = load("res://addons/event_system_plugin/assets/themes/timeline_editor.tres")


func _ready() -> void:
	timeline_displayer.connect("event_node_added", self, "_on_event_node_added")
	button_group.connect("pressed", self, "_on_event_node_pressed")
	timeline_list.connect("item_selected", self, "_timeline_selected")


func build_timeline(timeline) -> void:
	edited_timeline = timeline
	timeline_displayer.load_timeline(timeline)


func get_selected_event() -> Resource:
	var selected_event:Resource
	
	if is_instance_valid(last_selected_item):
		selected_event = last_selected_item.get("event")
	
	return selected_event


func _get_current() -> String:
	var current:String = ""
	var selected_id:int = timeline_list.get_selected_id()
	
	if selected_id >= 0 && selected_id < timeline_list.get_item_count():
		current = timeline_list.get_item_text(selected_id)
		
	return current


func _timeline_selected(_index:int) -> void:
	var current := _get_current()
	
	if current != "":
		var timeline = edited_node.get_timeline(current)
		build_timeline(timeline)


func _on_event_node_added(event_node) -> void:
	event_node.set_button_group(button_group)


func _on_event_node_pressed(button:Button) -> void:
	last_selected_item = button.get_meta("event_node")


func _on_ConfirmationDialog_confirmed():
	var event = get_selected_event()
	var event_idx = edited_timeline.get_event_idx(event)
	var current_timeline = _get_current()
	
	emit_signal("event_selected", event_idx, current_timeline)
