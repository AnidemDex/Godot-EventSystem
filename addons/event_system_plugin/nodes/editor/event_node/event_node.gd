extends HBoxContainer

## Event related to this node
var event:Event setget set_event
## The name of [member event]
var name_label:Label
## The description of [member event]
var description_label:Label

func expand() -> void:
	pass


func shrink() -> void:
	pass


func add_node(node:Control) -> void:
	var panel = PanelContainer.new()
	panel.focus_mode = Control.FOCUS_NONE
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.name = "Item %s"%get_child_count()
	panel.add_child(node)
	panel.show_behind_parent = true
	add_child(panel)
	
	var first_item = 0
	var last_item = get_child_count()-1
	var other_items = []
	for child_idx in get_child_count():
		if child_idx in [first_item, last_item]:
			continue
		other_items.append(child_idx)
	
	var child:PanelContainer
	for child_idx in other_items:
		child = get_child(child_idx) as PanelContainer
		if child == null:
			continue
		child.add_stylebox_override("panel", get_stylebox("bg", "EventNode"))
	
	child = get_child(first_item) as PanelContainer
	if child:
		child.add_stylebox_override("panel", get_stylebox("bg_left", "EventNode"))
	if get_child_count() > 1:
		child = get_child(last_item)
		if child:
			child.add_stylebox_override("panel", get_stylebox("bg_right","EventNode"))


func get_left_node() -> PanelContainer:
	if get_child_count() > 0:
		return get_child(0) as PanelContainer
	return null

func get_right_node() -> PanelContainer:
	if get_child_count() > 0:
		return get_child(get_child_count()-1) as PanelContainer
	return null


func set_event(_event) -> void:
	event = _event


func update_colors() -> void:
	var event_color:Color = Color.darkslategray
	var left_style:StyleBoxFlat = get_stylebox("bg_left", "EventNode")
	var right_style:StyleBoxFlat = get_stylebox("bg_right", "EventNode")
	var center_style:StyleBoxFlat = get_stylebox("bg", "EventNode")
	
	if event:
		event_color = event.event_color
	
	theme.set_color("event", "EventNode", event_color)
	theme.set_color("default", "EventNode", event_color.darkened(0.25))
	
	if event_color.v < 0.5:
		theme.set_color("font_color", "Label", Color.floralwhite)
		theme.set_color("font_color", "Label", Color.floralwhite)
	else:
		theme.set_color("font_color", "Label", Color.black)
		theme.set_color("font_color", "Label", Color.black)
	
	left_style.bg_color = get_color("event", "EventNode")
	left_style.border_width_right = 1
	left_style.border_color = get_color("default", "EventNode")
	right_style.bg_color = get_color("default", "EventNode")
	center_style.bg_color = get_color("default", "EventNode")


func update_event_name() -> void:
	var text := "{Event Name}"
	if event:
		text = event.event_name
	name_label.text = text
	

func update_event_description() -> void:
	var text := "{Event Description}"
	if event:
		text = event.event_preview_string
	description_label.text = text


func _update_values() -> void:
	update_colors()
	update_event_name()
	update_event_description()
	update()


func get_drag_data(position: Vector2):
	if not event:
		return null
	
	var node = self.duplicate(0)
	node.rect_size = Vector2.ZERO
	set_drag_preview(node)
	return event


func can_drop_data(position: Vector2, data) -> bool:
	return data is Event


###
# Fake methods
# methods called by notifications to avoid override virtual ones
###
func __fake_ready() -> void:
	_update_values()


func __fake_draw() -> void:
	var outline_stylebox:StyleBoxFlat = get_stylebox("outline", "EventNode")
	draw_style_box(outline_stylebox, Rect2(Vector2.ZERO, rect_size))


func __fake_focus_enter() -> void:
	var outline_stylebox:StyleBoxFlat = get_stylebox("outline", "EventNode")
	outline_stylebox.border_color = get_color("hover", "EventNode")


func __fake_focus_exit() -> void:
	var outline_stylebox:StyleBoxFlat = get_stylebox("outline", "EventNode")
	outline_stylebox.border_color = get_color("outline", "EventNode")


func __fake_mouse_enter() -> void:
	for style in [get_stylebox("bg","EventNode"), get_stylebox("bg_right","EventNode")]:
		style.bg_color = get_color("event", "EventNode")


func __fake_mouse_exit() -> void:
	for style in [get_stylebox("bg", "EventNode"), get_stylebox("bg_right", "EventNode")]:
		style.bg_color = get_color("default", "EventNode")


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_POST_ENTER_TREE:
			__fake_ready()
		NOTIFICATION_DRAW:
			__fake_draw()
		NOTIFICATION_FOCUS_ENTER:
			__fake_focus_enter()
		NOTIFICATION_FOCUS_EXIT:
			__fake_focus_exit()
		NOTIFICATION_MOUSE_ENTER:
			__fake_mouse_enter()
		NOTIFICATION_MOUSE_EXIT:
			__fake_mouse_exit()


func _init() -> void:
	
	theme = load("res://addons/event_system_plugin/assets/themes/event_node/event_node.tres") as Theme
	theme = theme.duplicate(true)
	rect_clip_content = true
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	name_label = Label.new()
	name_label.name = "EventName"
	add_node(name_label)
	
	description_label = Label.new()
	description_label.name = "EventDescription"
	add_node(description_label)
	
	connect("tree_exiting", name_label, "queue_free")
	connect("tree_exiting", description_label, "queue_free")
	
	for node in [name_label, description_label]:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.focus_mode = Control.FOCUS_NONE
		node.size_flags_horizontal = SIZE_EXPAND_FILL
		node.size_flags_vertical = SIZE_EXPAND_FILL
		node.align = Label.ALIGN_LEFT
		node.valign = Label.VALIGN_CENTER
	
	for node_idx in 2:
		var node:PanelContainer = get_child(node_idx) as PanelContainer
		if node_idx == 0:
			node.size_flags_stretch_ratio = 2
		else:
			node.size_flags_stretch_ratio = 8
		node.show_behind_parent = true
		node.size_flags_horizontal = SIZE_EXPAND_FILL
		node.size_flags_vertical = SIZE_EXPAND_FILL
