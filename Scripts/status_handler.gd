extends Node

var status_icons = {}

func _ready():
	load_assets("res://Prefabs/StatusIcons/", status_icons)

func apply_status(character, statusName, amount):
	var statusFolder = character.get_node_or_null("Status")
	
	if not statusFolder:
		print("No Status folder found for ", character.name)
		return
		
	var found_status = statusFolder.get_node_or_null(statusName)
	if found_status:
		var old_amount = found_status.get_meta("Amount")
		old_amount += amount
		
		found_status.set_meta("Amount", old_amount)
		update_icon(character, statusName, old_amount)
		return
	
	var new_status = Node2D.new()
	new_status.name = statusName
	new_status.set_meta("Amount", amount)
	
	statusFolder.add_child(new_status)
	create_status_icon(character, statusName, amount)
	
func remove_status(character, statusName, amount):
	var statusFolder = character.get_node_or_null("Status")
	
	if not statusFolder:
		print("No Status folder found for ", character.name)
		return
		
	var found_status = statusFolder.get_node_or_null(NodePath(statusName))
	if not found_status:
		print("No status called ", statusName, " found for ", character.name)
		return
		
	var old_amount = found_status.get_meta("Amount")
	old_amount -= amount
	
	if old_amount <= 0:
		found_status.queue_free()
		remove_status_icon(character, statusName)
		return
	
	found_status.set_meta("Amount", old_amount)
	
	update_icon(character, statusName, old_amount)
	
func create_status_icon(character, statusName, amount):
	if not status_icons.has(statusName):
		print("No icon found for ", statusName)
		return
		
	var StatusContainer = character.get_node_or_null("GUI/StatusContainer")
	
	if not StatusContainer:
		print("No StatusContainer found for ", character.name)
		return
	
	var icon = status_icons[statusName].instantiate()
	icon.get_node("Amount").text = str(amount)
	
	StatusContainer.add_child(icon)

func remove_status_icon(character, statusName):
	var StatusContainer = character.get_node_or_null("GUI/StatusContainer")
	
	if not StatusContainer:
		print("No StatusContainer found for ", character.name)
		return
	
	var found_icon = StatusContainer.get_node_or_null(statusName)
	
	if not found_icon:
		print("No icon found for ", statusName, " on ", character.name)
		return
	
	found_icon.queue_free()
	
func update_icon(character, statusName, amount):
	var StatusContainer = character.get_node_or_null("GUI/StatusContainer")
	
	if not StatusContainer:
		print("No StatusContainer found for ", character.name)
		return
	
	var found_icon = StatusContainer.get_node_or_null(NodePath(statusName))
	
	if not found_icon:
		print("No icon found for ", statusName, " on ", character.name)
		return
		
	found_icon.get_node("Amount").text = str(amount)

func load_assets(folder_path: String, dir_to_store_them: Dictionary) -> void:
	var dir = DirAccess.open(folder_path)
	if dir:
		for file_name in dir.get_files():
			if not file_name.ends_with(".tscn"):
				continue
			var scene: PackedScene = load(folder_path + file_name)
			if scene:
				var state = scene.get_state()
				var scene_name = state.get_node_name(0)
				dir_to_store_them[scene_name] = scene
