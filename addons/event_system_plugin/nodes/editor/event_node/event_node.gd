tool
extends HBoxContainer

const EventClass = preload("res://addons/event_system_plugin/resources/event_class/event_class.gd")
const TimelineClass = preload("res://addons/event_system_plugin/resources/timeline_class/timeline_class.gd")
const Utils = preload("res://addons/event_system_plugin/core/utils.gd")

var event_button:Button

## Event related to this node
var event:EventClass setget set_event

## Timeline that contains this event. Used as editor hint
var timeline:TimelineClass
var idx:int setget set_idx

# Background
var __bg:PanelContainer
var __indent_node:Control
var __header:HBoxContainer
var __body:MarginContainer
var __icon_container:PanelContainer
var __icon_node:TextureRect
var __event_label:Label
var __event_preview_label:Label
var __expand_button:CheckButton

func update_values() -> void:
	__update_event_icon()
	__update_event_name()
	__update_preview_hint()
	__update_identation()
	
	if has_method("_update_values"):
		call("_update_values")


func add_node_at_header(node:Control) -> void:
	__header.get_child(1).add_child(node)


func add_node_at_body(node:Control) -> void:
	__expand_button.visible = true
	__body.get_child(0).add_child(node)


func set_event(_event) -> void:
	if event and event.is_connected("changed",self,"update_values"):
		event.disconnect("changed",self,"update_values")
	
	event = _event
	
	if event != null:
		if not event.is_connected("changed",self,"update_values"):
			event.connect("changed",self,"update_values")
		name = event.event_name


func set_idx(value:int) -> void:
	idx = value


func set_indentation_level(level:int) -> void:
	if !is_instance_valid(__indent_node):
		return
	level = max(level, 0)
	__indent_node.rect_min_size.x = get_constant("indentation", "EventNode") * level


func set_button_group(button_group:ButtonGroup) -> void:
	event_button.set_button_group(button_group)


func _on_event_button_toggled(toggled:bool) -> void:
	var color:Color = Color.white
	var icon_color:Color = color
	if toggled:
		color = Color.cyan if not Engine.editor_hint else get_color("accent_color", "Editor")
		if event:
			icon_color = event.event_color
	
	event_button.self_modulate = color
	__icon_container.self_modulate = icon_color
	


func _on_expand_toggled(toggled:bool) -> void:
	__body.visible = toggled


func __update_event_name() -> void:
		var text := "{Event Name}"
		if event:
			text = event.event_name
		__event_label.text = text


func __update_event_icon() -> void:
	var icon:Texture = get_icon("warning", "EditorIcons")
	var color:Color = get_color("")
	if event:
		icon = event.event_icon
	
	__icon_node.texture = icon


func __update_preview_hint() -> void:
	var text:String = ""
	
	if event:
		text = event.event_preview_string
		
		if "next_event" in text:
			text = text.replace("next_event", "__next_event__")
		
		text = text.format(Utils.get_property_values_from(event))
		if "next_event" in event:
			var data = str(event.get("next_event")).split(";", false, 1)
			var next_idx = -1
			var event_name = "???"
			var timeline_name = ""
			var hint_string = "{event_name}"
			var used_timeline = timeline
			
			if data.size() >= 1:
				next_idx = int(data[0])
			if data.size() >= 2:
				timeline_name = str(data[1])
				hint_string += " from {timeline_name}"
				if is_instance_valid(Engine.get_meta("EventSystem").timeline_editor._edited_node):
					used_timeline = Engine.get_meta("EventSystem").timeline_editor._edited_node.get_timeline(timeline_name)
			
			if used_timeline.get_event(next_idx):
				event_name = used_timeline.get("event/"+str(next_idx)).resource_name
			
			hint_string = hint_string.format({"event_name":event_name, "timeline_name":timeline_name})
			text = text.format({"__next_event__":hint_string})
		
	
	__event_preview_label.text = text


func __update_identation() -> void:
	var indentation_level:int = 0
	if event:
		indentation_level = event.event_indent_level
	set_indentation_level(indentation_level)


func _notification(what):
	match what:
		NOTIFICATION_THEME_CHANGED, NOTIFICATION_ENTER_TREE:
			var none := StyleBoxEmpty.new()
			event_button.add_stylebox_override("normal", none)
			event_button.add_stylebox_override("hover", get_stylebox("hover", "EventNode"))
			event_button.add_stylebox_override("pressed", get_stylebox("pressed", "EventNode"))
			event_button.add_stylebox_override("focus", get_stylebox("hover", "EventNode"))
			
			__header.get_child(0).set_deferred("rect_min_size", Vector2(get_constant("margin_left", "EventNode"),0))
			
			var icon_bg = StyleBoxTexture.new()
			icon_bg.texture = get_icon("bg", "EventNode")
			__icon_container.add_stylebox_override("panel", icon_bg)
			
			__expand_button.add_icon_override("off", get_icon("unchecked", "EventNode"))
			__expand_button.add_icon_override("on", get_icon("checked", "EventNode"))
			
			__body.add_constant_override("margin_left", 50)
			
			var style = StyleBoxEmpty.new()
			style.content_margin_bottom = 3
			__bg.add_stylebox_override("panel", style)


func _init():
	name = "EventNode"
	size_flags_horizontal = SIZE_EXPAND_FILL
	rect_clip_content = true
	
	__indent_node = Control.new()
	
	__bg = PanelContainer.new()
	__bg.focus_mode = Control.FOCUS_NONE
	__bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	__bg.size_flags_horizontal = SIZE_EXPAND_FILL
	
	event_button = Button.new()
	event_button.toggle_mode = true
	event_button.focus_mode = Control.FOCUS_ALL
	event_button.mouse_filter = Control.MOUSE_FILTER_PASS
	event_button.name = "UIBehaviour"
	event_button.set_meta("event_node", self)
	event_button.connect("toggled", self, "_on_event_button_toggled")
	
	var vb = VBoxContainer.new()
	vb.focus_mode = Control.FOCUS_NONE
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	__header = HBoxContainer.new()
	__header.name = "Header"
	__header.focus_mode = Control.FOCUS_NONE
	__header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	__body = MarginContainer.new()
	__body.name = "Body"
	__body.focus_mode = Control.FOCUS_NONE
	__body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	__expand_button = CheckButton.new()
	__expand_button.visible = false
	__expand_button.connect("toggled", self, "_on_expand_toggled")
	__expand_button.set_pressed_no_signal(true)
	
	__icon_container = PanelContainer.new()
	__icon_node = TextureRect.new()
	__icon_node.name = "Icon"
	__icon_node.expand = true
	__icon_node.rect_min_size = Vector2(32,32)
	__icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	__icon_container.add_child(__icon_node)
	
	__event_label = Label.new()
	__event_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	__event_label.focus_mode = Control.FOCUS_NONE
	
	__event_preview_label = Label.new()
	__event_preview_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	__event_preview_label.focus_mode = Control.FOCUS_NONE
	
	var c := Control.new()
	c.focus_mode = Control.FOCUS_NONE
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	__header.add_child(c)
	
	var hb := HBoxContainer.new()
	hb.focus_mode = Control.FOCUS_NONE
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	__header.add_child(hb)
	__header.add_child(__expand_button)
	
	__body.add_child(VBoxContainer.new())
	
	vb.add_child(__header)
	vb.add_child(__body)
	
	__bg.add_child(event_button)
	__bg.add_child(vb)
	
	add_child(__indent_node)
	add_child(__bg)
	
	add_node_at_header(__icon_container)
	add_node_at_header(__event_label)
#	add_node_at_header(VSeparator.new())
	add_node_at_header(__event_preview_label)
