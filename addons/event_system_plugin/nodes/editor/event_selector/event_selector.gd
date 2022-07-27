tool
extends ConfirmationDialog

signal event_selected(event, timeline_path)

const TimelineDisplayer = preload("res://addons/event_system_plugin/nodes/editor/timeline_displayer.gd")
const TimelineList = preload("res://addons/event_system_plugin/nodes/editor/timeline_list.gd")

export(NodePath) var displayer_path:NodePath
export(NodePath) var list_path:NodePath
onready var timeline_displayer:TimelineDisplayer = get_node(displayer_path) as TimelineDisplayer
onready var timeline_list:TimelineList = get_node(list_path) as TimelineList

var last_selected_item = null
var external_path:String = ""
var used_timeline:Resource = null
var button_group = ButtonGroup.new()
var edited_node
var edited_timeline

func _notification(what):
	if what == NOTIFICATION_POPUP_HIDE:
		if not visible:
			set_deferred("external_path", "")
			set_deferred("used_timeline", null)
	
	if what == NOTIFICATION_POST_POPUP:
		edited_node = Engine.get_meta("EventSystem").timeline_editor._edited_node
		edited_timeline = Engine.get_meta("EventSystem").timeline_editor._edited_sequence
		
		timeline_list.node = edited_node
		timeline_list.list_timelines()


func _ready() -> void:
	timeline_displayer.connect("event_node_added", self, "_on_event_node_added")
	button_group.connect("pressed", self, "_on_event_node_pressed")
	timeline_list.connect("item_selected", self, "_timeline_selected")


func build_timeline(timeline) -> void:
	used_timeline = timeline
	timeline_displayer.load_timeline(timeline)


func get_selected_event() -> Resource:
	var selected_event:Resource = null
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


func _on_event_node_pressed(button) -> void:
	last_selected_item = button.get_meta("event_node")


func _on_ConfirmationDialog_confirmed():
	var event = get_selected_event()
	var events:Array = used_timeline.get_events()
	var event_idx = events.find(event)
	
	emit_signal("event_selected", event_idx, external_path)
