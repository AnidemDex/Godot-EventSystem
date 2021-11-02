tool
extends Resource

# Array of scripts (to keep their reference through the editor)
export(Array, Script) var events:Array = []

func _init() -> void:
	events = []
