tool
extends Animation
class_name Timeline

var clips:Array = [PoolIntArray([0,1])]

func _set(property: String, value) -> bool:
	if property.begins_with("clips"):
		var idx = int(property.split("/")[1])
		if idx < clips.size():
			clips[idx] = value
			return true
	
	return false


func _get(property: String):
	if property.begins_with("clips"):
		var idx = int(property.split("/")[1])
		if idx < clips.size():
			return clips[idx]


func _get_property_list() -> Array:
	var properties:Array = []
	for clip_idx in clips.size():
		properties.append(
			{
				"name":"clips/{clip_idx}".format({"clip_idx":clip_idx}),
				"type":TYPE_INT_ARRAY,
				"usage":PROPERTY_USAGE_STORAGE,
			}
		)
	return properties
