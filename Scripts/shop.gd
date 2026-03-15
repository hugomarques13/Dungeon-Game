extends Control

@onready var Units = $Units
@onready var Traps = $Traps
@onready var Fields = $Fields
@onready var TabName = $TabName
@onready var VContainer = $ScrollContainer/VBoxContainer
@onready var Template = $ScrollContainer/VBoxContainer/Template
@onready var SidePanel = $SidePanel
@onready var Player = $"../../Player"
@onready var UnitsHud = $"../Units"
@onready var UnitsHudContainer = $"../Units/ScrollContainer/HBoxContainer"
@onready var UnitsHudTemplate = $"../Units/ScrollContainer/HBoxContainer/Template"
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

var current_button = null

var currently_dragging = null

func _ready():
	pressed_icon(Units)

func _process(delta):
	if currently_dragging:
		currently_dragging.position = get_global_mouse_position()

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

func _on_shop_opener_pressed() -> void:
	visible = not visible

func _on_souls_background_pressed() -> void:
	var unit = SidePanel.get_node("ThingName/Label").text
	
	if not unit in units:
		print(unit, " doesn't exist")
		return
		
	purchase_unit(unit)

func _on_units_opener_pressed() -> void:
	UnitsHud.visible = not UnitsHud.visible

func flag_removed_unit(unit):
	var result = Player.add_unit(unit)
	update_unit_amount(unit, result)
	
