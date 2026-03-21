extends Sprite2D
var Units = {
	1: null,
	2: null,
	3: null,
	4: null
}
@onready var Spots = [
	$Spot1,
	$Spot2,
	$Spot3,
	$Spot4
]
@onready var Shop = $"../../HUD/Shop"
@onready var EnemyManager = $"../../Chibis"
@onready var NavRegion: NavigationRegion2D = $NavigationRegion2D
var _saved_units = {}
var field = ""

func is_full():
	for unit in Units.values():
		if unit == null:
			return false
	return true

func get_first_empty_slot():
	for key in Units.keys():
		print("key: ", key, "   value: ", Units[key])
		if Units[key] == null:
			return key
	return 0

func _attach_wanderer(chibi: Node2D) -> void:
	var sprite = chibi.get_node_or_null("AnimatedSprite2D")
	if not sprite:
		if chibi is AnimatedSprite2D:
			sprite = chibi
		else:
			print("No AnimatedSprite2D found on ", chibi.name)
			return
	var wanderer := preload("res://Scripts/FlagWanderer.gd").new()
	chibi.add_child(wanderer)
	wanderer.setup(chibi, sprite, NavRegion)

func _force_clear() -> void:
	# Remove every child from every spot regardless of what Units thinks,
	# so stale chibis with dead signal connections can't linger.
	for spot in Spots:
		for child in spot.get_children():
			child.queue_free()
	for key in Units.keys():
		Units[key] = null

func add_unit(unit: String, info):
	if is_full():
		print("This flag is full")
		Shop.flag_removed_unit(unit)
		return
	var index = get_first_empty_slot()
	Units[index] = unit
	var spot = Spots[index - 1]
	var chibi = info.Chibi.instantiate()
	chibi.name = unit
	spot.add_child(chibi)
	chibi.global_position = spot.global_position
	chibi.z_index = 1
	_attach_wanderer(chibi)
	chibi.get_node("Area2D").input_event.connect(func(viewport, event, shape_idx):
		if event is InputEventMouseButton and event.pressed:
			if EnemyManager.dungeon_state == "CLOSED":
				remove_unit(unit, index)
				viewport.set_input_as_handled()
	)

func remove_unit(unit: String, index):
	if Units[index] != unit:
		print(unit, " is not at ", index)
		return
	Units[index] = null
	var spot = Spots[index - 1]
	var chibi = spot.get_node_or_null(unit)
	if chibi:
		chibi.queue_free()
	Shop.flag_removed_unit(unit)

func unit_died(unit: String, index):
	if Units[index] != unit:
		print(unit, " is not at ", index)
		return
	Units[index] = null
	var spot = Spots[index - 1]
	var chibi = spot.get_node_or_null(unit)
	if chibi:
		chibi.queue_free()

func save_state():
	_saved_units = Units.duplicate()

func restore_state():
	_force_clear()

	for index in _saved_units.keys():
		var unit = _saved_units[index]
		if unit == null:
			continue
		if not Shop.units.has(unit):
			print("No unit info found for ", unit, " during flag restore")
			continue
		var info = Shop.units[unit]
		Units[index] = unit
		var spot = Spots[index - 1]
		var chibi = info.Chibi.instantiate()
		chibi.name = unit
		spot.add_child(chibi)
		chibi.global_position = spot.global_position
		chibi.z_index = 1
		_attach_wanderer(chibi)
		chibi.get_node("Area2D").input_event.connect(func(viewport, event, shape_idx):
			if event is InputEventMouseButton and event.pressed:
				if EnemyManager.dungeon_state == "CLOSED":
					remove_unit(unit, index)
					viewport.set_input_as_handled()
		)

func get_save_data() -> Dictionary:
	var units_data = {}
	for index in Units.keys():
		units_data[str(index)] = Units[index]
	return {
		"units": units_data,
		"field": field,
	}

func load_save_data(data: Dictionary) -> void:
	_force_clear()

	field = data.get("field", "")

	var units_data: Dictionary = data.get("units", {})
	for key in units_data.keys():
		var index = int(key)
		var unit = units_data[key]
		if unit == null:
			continue
		if not Shop.units.has(unit):
			print("No unit info found for ", unit, " during flag load")
			continue
		var info = Shop.units[unit]
		Units[index] = unit
		var spot = Spots[index - 1]
		var chibi = info.Chibi.instantiate()
		chibi.name = unit
		spot.add_child(chibi)
		chibi.global_position = spot.global_position
		chibi.z_index = 1
		_attach_wanderer(chibi)
		chibi.get_node("Area2D").input_event.connect(func(viewport, event, shape_idx):
			if event is InputEventMouseButton and event.pressed:
				if EnemyManager.dungeon_state == "CLOSED":
					remove_unit(unit, index)
					viewport.set_input_as_handled()
		)
