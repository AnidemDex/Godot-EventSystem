tool
extends Event
class_name EventGoTo

## Makes EventManager execute the defined event in [code]next_event[/code] instead
## of the directly next one.

# The next event hint of this event. "<index>;<timeline>"
var next_event:String = "" setget set_next_event

func _init() -> void:
	event_name = "Go to"
	event_color = Color("#FBB13C")
	event_preview_string = "event [{next_event}]"
	continue_at_end = true
	event_category = "Logic"
	event_hint = "Helper event to define the next event after this event"

func set_next_event(value:String) -> void:
	next_event = value
	emit_changed()
	property_list_changed_notify()


func _get(property):
	if property == "event_node_path_ignore":
		return true
	if property == "continue_at_end_ignore":
		return true


func _get_property_list():
	var p := []
	p.append({"name":"next_event", "type":TYPE_STRING})
	return p
