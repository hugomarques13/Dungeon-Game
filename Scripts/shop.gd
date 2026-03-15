extends Control

@onready var Units = $Units
@onready var Traps = $Traps
@onready var Fields = $Fields
@onready var TabName = $TabName
@onready var VContainer = $ScrollContainer/VBoxContainer
@onready var Template = $ScrollContainer/VBoxContainer/Template
@onready var SidePanel = $SidePanel
@onready var Player = $"../../Player"
@onready var TopBar = $"../TopBar"
@onready var UnitsHudContainer = $"../TopBar/UnitsContainer/HBoxContainer"
@onready var UnitsHudTemplate = $"../TopBar/UnitsContainer/HBoxContainer/Template"
@onready var TrapsHudContainer = $"../TopBar/TrapsContainer/HBoxContainer"
@onready var TrapsHudTemplate = $"../TopBar/TrapsContainer/HBoxContainer/Template"
@onready var ChibiPlace = $"../../ChibiPlace"

const FLAG_DROP_RANGE = 90

const baseIcons = {
	"Units" = preload("res://Sprites/HUD/Shop/IconUnits.png"),
	"Traps" = preload("res://Sprites/HUD/Shop/IconTraps.png"),
	"Fields" = preload("res://Sprites/HUD/Shop/IconFields.png")
}

const activeIcons = {
	"Units" = preload("res://Sprites/HUD/Shop/IconUnits2.png"),
	"Traps" = preload("res://Sprites/HUD/Shop/IconTraps2.png"),
	"Fields" = preload("res://Sprites/HUD/Shop/IconFields2.png")
}

const iconTitles = {
	"Units" = "Wicked Contracts",
	"Traps" = "Trappy",
	"Fields" = "Like Yu-Gi-Oh"
}

const units = {
	"Lesser Zombie" = {
		LoreDescription = "\"Cheap souls long cast aside, taken in by neither Heaven nor Hell. Lowest of the low. Thus perfect for our uses.\"",
		SkillsDescription = "He hits people with his nasty aaa hands.",
		Cost = 1,
		UnlockCost = 2,
		Icon = preload("res://Sprites/HUD/Shop/placeh.png"),
		Chibi = preload("res://Prefabs/Chibis/placeholder.tscn")
	},
	"Greater Zombie" = {
		LoreDescription = "TO DO",
		SkillsDescription = "TO DO SKILLS",
		Cost = 5,
		UnlockCost = 10,
		Icon = preload("res://Sprites/HUD/Shop/placeh.png"),
		Chibi = preload("res://Prefabs/Chibis/placeholder.tscn")
	},
	"Grave Thief" = {
		LoreDescription = "TO DO",
		SkillsDescription = "TO DO SKILLS",
		Cost = 5,
		UnlockCost = 20,
		Icon = preload("res://Sprites/HUD/Shop/placeh.png"),
		Chibi = preload("res://Prefabs/Chibis/placeholder.tscn")
	},
	"Skeleton" = {
		LoreDescription = "TO DO",
		SkillsDescription = "TO DO SKILLS",
		Cost = 5,
		UnlockCost = 30,
		Icon = preload("res://Sprites/HUD/Shop/placeh.png"),
		Chibi = preload("res://Prefabs/Chibis/placeholder.tscn")
	},
	"Undead Archers" = {
		LoreDescription = "TO DO",
		SkillsDescription = "TO DO SKILLS",
		Cost = 10,
		UnlockCost = 40,
		Icon = preload("res://Sprites/HUD/Shop/placeh.png"),
		Chibi = preload("res://Prefabs/Chibis/placeholder.tscn")
	},
}

const traps = {
	"Spikes" = {
		LoreDescription = "A crude but effective trap",
		SkillsDescription = "Does damage to the party",
		Cost = 5,
		UnlockCost = 20,
		Icon = preload("res://Sprites/HUD/Shop/placeh.png"),
		Scene = preload("res://Prefabs/Traps/Spikes.tscn")
	},
}

var current_button = null

var currently_dragging = null

var placement_preview: Polygon2D = null
var last_mouse_pos = Vector2.ZERO
var cached_nearest_tile = null

func _ready():
	pressed_icon(Units)

func _process(delta):
	if currently_dragging:
		currently_dragging.position = get_global_mouse_position()
		update_trap_preview()

func _on_units_pressed() -> void:
	pressed_icon(Units)

func _on_traps_pressed() -> void:
	pressed_icon(Traps)

func _on_fields_pressed() -> void:
	pressed_icon(Fields)

func reset_icon(button: TextureButton):
	if button:
		button.texture_normal = baseIcons[button.name]

func pressed_icon(button: TextureButton):
	reset_icon(current_button)
	current_button = button
	button.texture_normal = activeIcons[button.name]
	TabName.get_node("Label").text = iconTitles[button.name]
	clean_VContainer()

	if button == Units:
		generate_units()
	elif button == Traps:
		generate_traps()

	SidePanel.visible = false

func clean_VContainer():
	for button in VContainer.get_children():
		if button != Template:
			button.queue_free()

func generate_units():
	for unit in units.keys():
		var info = units[unit]
		var is_unlocked = Player.is_unit_unlocked(unit)
		
		var new_button = Template.duplicate()
		new_button.name = unit
		new_button.visible = true
		new_button.get_node("Icon").texture = info.Icon
		
		if is_unlocked:
			new_button.get_node("Locked").visible = false
			new_button.get_node("Amount").visible = true
			new_button.get_node("Amount").text = str(Player.get_unit_amount(unit))
			new_button.get_node("Cost").text = str(info.Cost)
			
			create_placement_unit_icon(unit)
		else:
			new_button.get_node("Locked").visible = true
			new_button.get_node("Amount").visible = false
			new_button.get_node("Cost").text = str(info.UnlockCost)
		
		new_button.pressed.connect(func():
			print(unit, " clicked")
			SidePanel.visible = true
			SidePanel.get_node("ThingName/Label").text = unit
			SidePanel.get_node("Description/Label").text = info.LoreDescription
			SidePanel.get_node("UseName/Label").text = "Skill"
			SidePanel.get_node("UseDescription/Label").text = info.SkillsDescription
			
			if is_unlocked:
				SidePanel.get_node("SoulsBackground/Cost").text = str(info.Cost)
				SidePanel.get_node("SoulsBackground/Label").text = "Buy"
			else:
				SidePanel.get_node("SoulsBackground/Cost").text = str(info.UnlockCost)
				SidePanel.get_node("SoulsBackground/Label").text = "Unlock"
		)
		
		VContainer.add_child(new_button)
		
func update_unit_amount(unit: String, new_amount):
	var unit_node = VContainer.get_node_or_null(unit)
	
	if not unit_node:
		print("Unit node for ", unit, " not found")
		return
		
	unit_node.get_node("Amount").text = str(new_amount)
	
	var units_hud_icon = UnitsHudContainer.get_node_or_null(unit)
	
	if not units_hud_icon:
		print("Units hud icon for ", unit, " not found")
		return
	
	units_hud_icon.get_node("Amount").text = str(new_amount)

func purchase_unit(unit: String):
	var info = units[unit]
	if Player.is_unit_unlocked(unit):
		var result = Player.remove_souls(info.Cost)
		if result:
			var new_amount = Player.add_unit(unit)
			
			if not new_amount:
				print("newAmount is null")
				return
			
			update_unit_amount(unit, new_amount)
	else:
		var result = Player.remove_souls(info.UnlockCost)
		if result:
			var unlock_result = Player.unlock_unit(unit)
			
			if not unlock_result:
				print("unlock_result is null")
				return
			
			create_placement_unit_icon(unit)
			
			update_unit_amount(unit, 0)
			
			SidePanel.get_node("SoulsBackground/Cost").text = str(info.Cost)
			SidePanel.get_node("SoulsBackground/Label").text = "Buy"
			
			var unit_node = VContainer.get_node_or_null(unit)
			
			if not unit_node:
				print("Unit node for ", unit, " not found")
				return
			
			unit_node.get_node("Amount").visible = true
			unit_node.get_node("Locked").visible = false
			unit_node.get_node("Cost").text = str(info.Cost)

func create_placement_unit_icon(unit):
	if UnitsHudContainer.get_node_or_null(NodePath(unit)):
		return
	
	var info = units[unit]
	var new_button = UnitsHudTemplate.duplicate()
	new_button.name = unit
	new_button.visible = true
	
	new_button.get_node("Icon").texture = info.Icon
	new_button.get_node("Amount").visible = true
	new_button.get_node("Amount").text = str(Player.get_unit_amount(unit))
	new_button.get_node("Cost").text = str(info.Cost)
	
	new_button.button_down.connect(func():
		if Player.get_unit_amount(unit) == 0:
			purchase_unit(unit)

		var result = Player.remove_unit(unit)
		
		if result == null:
			print("Removing failed for ", unit)
			return
			
		update_unit_amount(unit, result)
		
		currently_dragging = info.Chibi.instantiate()
		ChibiPlace.add_child(currently_dragging)
	)
	
	new_button.button_up.connect(func():
		var placed = false
		if currently_dragging:
			for flag in get_tree().get_nodes_in_group("Flag"):
				var distance = currently_dragging.global_position.distance_to(flag.global_position)
				print("Checking ", flag, " with distance ", distance)
				if distance <= FLAG_DROP_RANGE:
					flag.add_unit(unit, info)
					placed = true
					print("Found place")
					break
			
			if not placed:
				var result = Player.add_unit(unit)
				update_unit_amount(unit, result)
			
			currently_dragging.queue_free()
			currently_dragging = null
	)
	
	UnitsHudContainer.add_child(new_button)
	
func generate_traps():
	for trap in traps.keys():
		var info = traps[trap]
		var is_unlocked = Player.is_trap_unlocked(trap)

		var new_button = Template.duplicate()
		new_button.name = trap
		new_button.visible = true
		new_button.get_node("Icon").texture = info.Icon

		if is_unlocked:
			new_button.get_node("Locked").visible = false
			new_button.get_node("Amount").visible = true
			new_button.get_node("Amount").text = str(Player.get_trap_amount(trap))
			new_button.get_node("Cost").text = str(info.Cost)

			create_placement_trap_icon(trap)
		else:
			new_button.get_node("Locked").visible = true
			new_button.get_node("Amount").visible = false
			new_button.get_node("Cost").text = str(info.UnlockCost)

		new_button.pressed.connect(func():
			SidePanel.visible = true
			SidePanel.get_node("ThingName/Label").text = trap
			SidePanel.get_node("Description/Label").text = info.LoreDescription
			SidePanel.get_node("UseName/Label").text = "Effect"
			SidePanel.get_node("UseDescription/Label").text = info.SkillsDescription

			if is_unlocked:
				SidePanel.get_node("SoulsBackground/Cost").text = str(info.Cost)
				SidePanel.get_node("SoulsBackground/Label").text = "Buy"
			else:
				SidePanel.get_node("SoulsBackground/Cost").text = str(info.UnlockCost)
				SidePanel.get_node("SoulsBackground/Label").text = "Unlock"
		)

		VContainer.add_child(new_button)

func update_trap_amount(trap: String, new_amount):
	var trap_node = VContainer.get_node_or_null(trap)

	if not trap_node:
		print("Trap node for ", trap, " not found")
		return

	trap_node.get_node("Amount").text = str(new_amount)

	var traps_hud_icon = TrapsHudContainer.get_node_or_null(trap)

	if not traps_hud_icon:
		print("Traps hud icon for ", trap, " not found")
		return

	traps_hud_icon.get_node("Amount").text = str(new_amount)

func purchase_trap(trap: String):
	var info = traps[trap]
	if Player.is_trap_unlocked(trap):
		var result = Player.remove_souls(info.Cost)
		if result:
			var new_amount = Player.add_trap(trap)

			if not new_amount:
				print("new_amount is null")
				return

			update_trap_amount(trap, new_amount)
	else:
		var result = Player.remove_souls(info.UnlockCost)
		if result:
			var unlock_result = Player.unlock_trap(trap)

			if not unlock_result:
				print("unlock_result is null")
				return

			create_placement_trap_icon(trap)
			update_trap_amount(trap, 0)

			SidePanel.get_node("SoulsBackground/Cost").text = str(info.Cost)
			SidePanel.get_node("SoulsBackground/Label").text = "Buy"

			var trap_node = VContainer.get_node_or_null(trap)

			if not trap_node:
				print("Trap node for ", trap, " not found")
				return

			trap_node.get_node("Amount").visible = true
			trap_node.get_node("Locked").visible = false
			trap_node.get_node("Cost").text = str(info.Cost)

func create_placement_trap_icon(trap: String):
	if TrapsHudContainer.get_node_or_null(NodePath(trap)):
		return

	var info = traps[trap]
	var new_button = TrapsHudTemplate.duplicate()
	new_button.name = trap
	new_button.visible = true

	new_button.get_node("Icon").texture = info.Icon
	new_button.get_node("Amount").visible = true
	new_button.get_node("Amount").text = str(Player.get_trap_amount(trap))
	new_button.get_node("Cost").text = str(info.Cost)

	new_button.button_down.connect(func():
		if Player.get_trap_amount(trap) == 0:
			purchase_trap(trap)

		var result = Player.remove_trap(trap)

		if result == null:
			print("Removing failed for ", trap)
			return

		update_trap_amount(trap, result)

		currently_dragging = info.Scene.instantiate()
		currently_dragging.visible = true
		ChibiPlace.add_child(currently_dragging)

		create_trap_preview()
	)

	new_button.button_up.connect(func():
		if currently_dragging:
			var nearest = get_nearest_floor_tile(get_global_mouse_position())
			var placed = false

			if nearest and not is_tile_occupied(nearest):
				currently_dragging.global_position = nearest.global_position
				currently_dragging.visible = true
				currently_dragging.set_meta("tile", nearest)
				currently_dragging.set_meta("trap_name", trap)
				currently_dragging.add_to_group("PlacedTraps")
				
				placed = true
				
				var tile_parent = nearest.get_parent()
				ChibiPlace.remove_child(currently_dragging)
				tile_parent.add_child(currently_dragging)
				
				var trap_placed = currently_dragging

				currently_dragging.get_node("ClickBox").input_event.connect(func(viewport, event, shape_idx):
					if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
						trap_clicked(trap_placed)
				)

			if not placed:
				var result = Player.add_trap(trap)
				update_trap_amount(trap, result)
				currently_dragging.queue_free()

			clear_trap_preview()
			currently_dragging = null
	)

	TrapsHudContainer.add_child(new_button)
	
func trap_clicked(trap_node: Node):
	if not trap_node.has_meta("trap_name"):
		print("Couldn't find trap name")
		return

	var trap_name = trap_node.get_meta("trap_name")

	trap_node.remove_from_group("PlacedTraps")
	trap_node.queue_free()

	var result = Player.add_trap(trap_name)
	update_trap_amount(trap_name, result)

func _on_shop_opener_pressed() -> void:
	visible = not visible

func _on_souls_background_pressed() -> void:
	var thing_name = SidePanel.get_node("ThingName/Label").text

	if thing_name in units:
		purchase_unit(thing_name)
	elif thing_name in traps:
		purchase_trap(thing_name)
	else:
		print(thing_name, " doesn't exist")

func _on_units_opener_pressed() -> void:
	TopBar.visible = not TopBar.visible

func flag_removed_unit(unit):
	var result = Player.add_unit(unit)
	update_unit_amount(unit, result)
	
	
func get_nearest_floor_tile(pos: Vector2):
	var nearest = null
	var nearest_dist = INF
	for tile in get_tree().get_nodes_in_group("FloorTile"):
		var dist = pos.distance_to(tile.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = tile
	return nearest

func is_tile_occupied(tile: Node) -> bool:
	for existing in get_tree().get_nodes_in_group("PlacedTraps"):
		if existing.get_meta("tile") == tile:
			return true
	return false

func update_trap_preview():
	if not placement_preview:
		return

	var mouse_pos = get_global_mouse_position()

	if mouse_pos != last_mouse_pos:
		last_mouse_pos = mouse_pos
		cached_nearest_tile = get_nearest_floor_tile(mouse_pos)

	if not cached_nearest_tile:
		placement_preview.visible = false
		return

	placement_preview.visible = true
	placement_preview.global_position = cached_nearest_tile.global_position

	if is_tile_occupied(cached_nearest_tile):
		placement_preview.color = Color(1, 0, 0, 0.4)
	else:
		placement_preview.color = Color(0, 1, 0, 0.4)

func create_trap_preview():
	placement_preview = Polygon2D.new()
	placement_preview.polygon = PackedVector2Array([
		Vector2(0, -48),   # top
		Vector2(77, 0),    # right
		Vector2(0, 48),    # bottom
		Vector2(-77, 0)    # left
	])
	placement_preview.color = Color(0, 1, 0, 0.4)
	get_tree().root.add_child(placement_preview)

func clear_trap_preview():
	if placement_preview:
		placement_preview.queue_free()
		placement_preview = null
