extends AnimationPlayer
class_name EventPlayer


func resume() -> void:
	play()


func pause() -> void:
	stop(false)
