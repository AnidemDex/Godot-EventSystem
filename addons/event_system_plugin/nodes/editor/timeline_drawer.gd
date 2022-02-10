extends Control

const TimelineDisplayer = preload("res://addons/event_system_plugin/nodes/editor/timeline_displayer.gd")
const EventNode = preload("res://addons/event_system_plugin/nodes/editor/event_node/event_node.gd")

var timeline_displayer:TimelineDisplayer setget set_timeline_displayer

func set_timeline_displayer(displayer:TimelineDisplayer) -> void:
	if is_instance_valid(timeline_displayer):
		if timeline_displayer.is_connected("load_ended", self, "_load_ended"):
			timeline_displayer.disconnect("load_ended",self,"_load_ended")
		if timeline_displayer.is_connected("draw", self, "_displayer_draw"):
			timeline_displayer.disconnect("draw", self, "_displayer_draw")
	
	timeline_displayer = displayer
	
	if is_instance_valid(timeline_displayer):
		timeline_displayer.connect("load_ended", self, "_load_ended")
		timeline_displayer.connect("draw", self, "_displayer_draw")


func _displayer_draw() -> void:
	var child_size:int = timeline_displayer.get_children().size()
	for node_idx in child_size:
		var prev_node:Control
		var node:Control
		var next_node:Control
		
		if node_idx > 0:
			prev_node = timeline_displayer.get_child(node_idx-1)
		if node_idx < child_size and node_idx+1 < child_size:
			next_node = timeline_displayer.get_child(node_idx+1)
		
		var start:Vector2 = Vector2()
		var end:Vector2 = Vector2()
		
		if prev_node:
			start = prev_node.rect_position
		if node:
			end = node.rect_position
		
		timeline_displayer.draw_line(start, end, Color.pink)
		
		if node:
			start = node.rect_position
		if next_node:
			end = next_node.rect_position
		
		timeline_displayer.draw_line(start, end, Color.chocolate)


func _load_ended() -> void:
	pass
