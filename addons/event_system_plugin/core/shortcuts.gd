extends Reference

static func get_shortcut(property: String) -> ShortCut:
	var shortcut:ShortCut = ShortCut.new()
	match property:
		"duplicate":
			shortcut = null
			if Engine.editor_hint:
				var plugin = ClassDB.instance("EditorPlugin")
				var settings:EditorSettings = plugin.get_editor_interface().get_editor_settings()
				shortcut = settings.get_setting("scene_tree/duplicate") as ShortCut
				plugin.free()
			
			if shortcut == null:
				shortcut = ShortCut.new()
				var input := InputEventKey.new()
				input.scancode = KEY_D
				input.control = true
				input.pressed = true
				shortcut.shortcut = input
		
		"remove","delete":
			shortcut = null
			
			if Engine.editor_hint:
				var plugin = ClassDB.instance("EditorPlugin")
				var settings:EditorSettings = plugin.get_editor_interface().get_editor_settings()
				shortcut = settings.get_setting("scene_tree/delete") as ShortCut
				plugin.free()
			
			if shortcut == null:
				shortcut = ShortCut.new()
				var input := InputEventKey.new()
				input.scancode = KEY_DELETE
				input.pressed = true
				shortcut.shortcut = input
				
	
	return shortcut
