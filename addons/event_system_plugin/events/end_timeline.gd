tool
extends Event

## Ends the timeline execution.

func _init() -> void:
	event_color = Color("EB5E55")
	event_name = "End Timeline"
	event_hint = "Terminates the execution of the timeline at this point"


func _execute() -> void:
	get_event_manager_node().call("_notify_timeline_end")
	get_event_manager_node().set("current_timeline", "")
	finish()
