extends Reference

## Util function to get a dictionary of object property:value
static func get_property_values_from(object:Object) -> Dictionary:
	if object == null:
		return {}
	var dict = {}
	# Hope this doesn't freeze the engine per call
	for property in object.get_property_list():
		dict[property.name] = object.get(property.name)
	return dict

