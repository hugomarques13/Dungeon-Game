@tool
extends EditorScript

func _run() -> void:
	var shader = load("res://Scripts/HitFlash.gdshader")
	var folders = ["res://Prefabs/Allies/", "res://Prefabs/Enemies/"]
	
	for folder in folders:
		var dir = DirAccess.open(folder)
		if not dir:
			print("Could not open: ", folder)
			continue
		
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var path = folder + file_name
				var scene = load(path)
				var root = scene.instantiate()
				
				var sprite = root.get_node_or_null("Sprite2D")
				if sprite:
					var mat = ShaderMaterial.new()
					mat.shader = shader
					sprite.material = mat
					
					var packed = PackedScene.new()
					packed.pack(root)
					ResourceSaver.save(packed, path)
					print("Updated: ", file_name)
				else:
					print("No Sprite2D found in: ", file_name)
				
				root.queue_free()
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	print("Done!")
