tool
extends Event
class_name EventComment

## A single comment. 
## It does nothing and can be used as a label point for Go To event.

export(String, MULTILINE) var text:String = "" setget set_text

func _init() -> void:
	event_name = "Comment"
	event_preview_string = "# {text}"
	event_hint = "Makes comment in the timeline.\nThis doesn't affects the timeline behaviour."
	event_color = Color("#3C3D5E")
	continue_at_end = true


func _execute(_event_node=null) -> void:
	finish()


func set_text(value:String) -> void:
	text = value
	property_list_changed_notify()
	emit_changed()

func _get(property: String):
	if property == "continue_at_end_ignore":
		return true
