tool
extends Event
class_name EventWait

## Pauses the timeline execution by [code]wait_time[/code] seconds.

export(float) var wait_time = 0.0 setget set_wait_time

func _init():
	event_name = "Wait"
	event_color = Color("#FBB13C")
	event_category = "Logic"
	event_preview_string = "[{wait_time}] seconds before the next event."


func _execute() -> void:
	var _timer = get_event_node().get_tree().create_timer(wait_time)
	_timer.connect("timeout", self, "finish")


func set_wait_time(value:float) -> void:
	wait_time = value
	emit_changed()
	property_list_changed_notify()
