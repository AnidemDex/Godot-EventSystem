tool
extends Event

func _init() -> void:
	event_color = Color("EB5E55")
	event_name = "Hide"
	event_category = "Logic"


func _execute() -> void:
	event_node.set("visible", false)    
	finish()
