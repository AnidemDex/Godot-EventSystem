tool
extends Node
class_name EventManager

##
## Base class for all event manager nodes.
##
## EventManager executes the event behaviour, and manages the event order execution.
## 

signal custom_signal(data)

## Emmited when an Event is executed. Event resource is passed in the signal
signal event_started(event)
## Emmited when an Event finished. Event resource is passed in the signal.
signal event_finished(event)

## Emmited when a timeline starts. Timeline resource is passed in the signal
signal timeline_started(timeline_resource)
## Emmited when a timeline finish. Timeline resource is passed in the signal
signal timeline_finished(timeline_resource)

## This is the node were events will be applied to.
## This node is used if the event doesn't define an [member Event.event_node_path]
## and is relative to the current scene node owner.
export(NodePath) var event_node_fallback_path:NodePath = "."
## If is [code]true[/code], the node will call [method start_timeline] when owner is ready.
export(bool) var start_on_ready:bool = false

## Current timeline name. You can get the current timeline resource with [method get_timeline]
var current_timeline:String=""
## Current executed event.
var current_event
## The current event position accordint to [member current_timeline] resource.
var current_idx:int = -1

var __data := {}

func _ready() -> void:
	if Engine.editor_hint:
		return
	
	if start_on_ready:
		call_deferred("start_timeline", current_timeline)

## Starts timeline. This method must be called to start EventManager process.
## [code]timeline_name[/code] is the name of any timeline saved in the node.
## You can optionally pass [code]from_event_index[/code] to define from
## where the timeline should start.
func start_timeline(timeline_name:String, from_event_index:int=0) -> void:
	if timeline_name == "[None]":
		return
	
	if !has_timeline(timeline_name):
		push_error("start_timeline: Can't find %p timeline"%timeline_name)
		return
	
	current_timeline = timeline_name
	_notify_timeline_start()
	go_to_next_event()

## Advances to the next event in the current timeline.
func go_to_next_event() -> void:
	var event
	
	if current_timeline == "" or !has_timeline(current_timeline):
		# For some reason, the current timeline doesn't exist
		
		return
	
	
	if current_event:
		if "next_event" in current_event and current_event["next_event"] != "":
			var data = current_event.get("next_event").split(";")
			current_idx = int(data[0])
			var new_timeline = ""
			if data.size() > 1:
				new_timeline = data[1]
			
			if new_timeline != "":
				current_timeline = new_timeline
		else:
			current_idx += 1
	
	if current_idx < 0:
		current_idx = 0
	
	var timeline = get_timeline(current_timeline)
	
	event = timeline.get("event/{idx}".format({"idx":current_idx}))
	current_event = event
	
	if current_event == null:
		_notify_timeline_end()
		return
	
	_execute_event(event)

## Adds a [code]timeline[/code] to this node named [code]timeline_name[/code].
func add_timeline(timeline_name:String, timeline) -> void:
	if timeline_name == "":
		push_error("add_timeline: Tried to add a timeline with an empty name!")
		return
	
	if timeline == null:
		push_error("add_timeline: Tried to add '%s' with a null value"%timeline_name)
		return
	
	if has_timeline(timeline_name):
		push_error("add_timeline: Timeline '%s' already exist"%timeline_name)
		return
	
	__data[timeline_name] = timeline
	property_list_changed_notify()

## Returns the [code]timeline[/code] associated to [code]timeline_name[/code]
func get_timeline(timeline_name:String) -> Timeline:
	var res = null
	
	if !has_timeline(timeline_name):
		push_error("get_timeline: Can't find {n} timeline".format({"n":timeline_name}))
	
	res = __data.get(timeline_name, null)
	return res

## Returns true if the node has a [code]timeline_name[/code]
func has_timeline(timeline_name:String) -> bool:
	return __data.has(timeline_name)

## Removes the timeline associated to [code]timeline_name[/code]
func remove_timeline(timeline_name:String) -> void:
	if !has_timeline(timeline_name):
		push_warning("remove_timeline: Tried to remove '%s' timeline but the timeline doesn't exist."%timeline_name)
		return
	__data.erase(timeline_name)
	property_list_changed_notify()

## Renames [code]timeline_name[/code] to [code]new_name[/code]
func rename_timeline(timeline_name:String, new_name:String) -> void:
	var timeline:Timeline = get_timeline(timeline_name)
	
	if !has_timeline(timeline_name):
		push_warning("rename_timeline: Tried to rename '%s' timeline but the timeline doesn't exist."%timeline_name)
		return
	
	if has_timeline(new_name):
		push_warning("rename_timeline: Tried to rename '{name}' timeline to '{new_name}' but '{new_name}' already exist.".format({"name":timeline_name, "new_name":new_name}))
		return
	
	remove_timeline(timeline_name)
	add_timeline(new_name, timeline)

## Returns a [class PoolStringArray] containing timeline names saved on this node.
func get_timeline_list() -> PoolStringArray:
	return PoolStringArray(__data.keys())


func _execute_event(event:Event) -> void:
	if event == null:
		assert(false)
		return
	
	var node:Node = self if event_node_fallback_path == @"." else get_node(event_node_fallback_path)
	# This is a crime, needs to be modified in future versions
	event.set("_event_manager", self)
	event.set("_event_node_fallback", node)
	
	_connect_event_signals(event)
	
	event.execute()


func _connect_event_signals(event:Event) -> void:
	if not event.is_connected("event_started", self, "_on_Event_started"):
		event.connect("event_started", self, "_on_Event_started", [], CONNECT_ONESHOT)
	if not event.is_connected("event_finished", self, "_on_Event_finished"):
		event.connect("event_finished", self, "_on_Event_finished", [], CONNECT_ONESHOT)


func _on_Event_started(event:Event) -> void:
	emit_signal("event_started", event)


func _on_Event_finished(event:Event) -> void:
	emit_signal("event_finished", event)
	if event.continue_at_end:
		go_to_next_event()


func _notify_timeline_start() -> void:
	emit_signal("timeline_started", get_timeline(current_timeline))


func _notify_timeline_end() -> void:
	emit_signal("timeline_finished", get_timeline(current_timeline))


func _hide_script_from_inspector():
	return true


func _set(property:String, value) -> bool:
	if property == "timeline":
		property = "timeline/legacy_timeline"
	
	if property.begins_with("timeline/"):
		var p := property.replace("timeline/", "")
		if p == "":
			return false
		
		add_timeline(p, value)
		property_list_changed_notify()
		
		return true
	
	return false


func _get(property: String):
	if property.begins_with("timeline/"):
		var p := property.replace("timeline/", "")
		if p == "":
			return
		
		return get_timeline(p)


func property_can_revert(property:String) -> bool:
	if property == "current_timeline":
		return true
	return false


func property_get_revert(property:String):
	if property == "current_timeline":
		return "[None]"


func _get_property_list() -> Array:
	var p := []
	var hint_string = "[None]"
	for timeline_name in get_timeline_list():
		hint_string += ",%s"%timeline_name
	p.append({"type":TYPE_STRING, "name":"current_timeline", "hint":PROPERTY_HINT_ENUM, "hint_string":hint_string, "usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_DEFAULT})
	
	var usage := PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_NOEDITOR
	for timeline_name in __data.keys():
		p.append({"type":TYPE_OBJECT, "name":"timeline/"+timeline_name, "usage":usage})
	return p
