extends Sprite2D

# Dictionary because this way we can have something in 3 but not in 1 or 2
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

func add_unit(unit: String, info):
	if is_full():
		print("This flag is full")
		Shop.flag_removed_unit(unit)
		return
	
	var index = get_first_empty_slot()
	Units[index] = unit
	
	var spot = Spots[index-1]
	
	var chibi = info.Chibi.instantiate()
	chibi.name = unit
	spot.add_child(chibi)
	
	chibi.global_position = spot.global_position
	
	print("Placed ", unit)
	
	chibi.get_node("Area2D").input_event.connect(func(viewport, event, shape_idx):
		if event is InputEventMouseButton and event.pressed:
			remove_unit(unit, index)
	)

func remove_unit(unit: String, index):
	if Units[index] != unit:
		print(unit, " is not at ", index)
		return
	
	Units[index] = null
	
	var spot = Spots[index-1]
	
	var chibi = spot.get_node_or_null(unit)
	
	if chibi:
		chibi.queue_free()
	
	Shop.flag_removed_unit(unit)
	
func unit_died(unit: String, index):
	if Units[index] != unit:
		print(unit, " is not at ", index)
		return
	
	Units[index] = null
	
	var spot = Spots[index-1]
	
	var chibi = spot.get_node_or_null(unit)
	
	if chibi:
		chibi.queue_free()
