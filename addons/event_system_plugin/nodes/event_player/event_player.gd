extends AnimationPlayer
class_name EventPlayer


func resume() -> void:
	play()


func pause() -> void:
	stop(false)


func _on_Event_finished(event) -> void:
	pass
