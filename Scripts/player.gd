extends Node2D
@onready var SoulsHud = $"../HUD/Souls"
var unlocked_units = [
	"Lesser Zombie"
]
var unlocked_traps = []
var unlocked_fields = []
var unit_inventory = {}
var traps_inventory = {}
var fields_inventory = {}
var souls = 40
var _saved_state = null

func _ready():
	_try_load_from_file()
	update_souls_ui()

func _try_load_from_file() -> void:
	var data = SaveManager.load_save()
	if data.is_empty():
		return
	var player_data = data.get("player", {})
	if player_data.is_empty():
		return
	souls = int(player_data.get("souls", souls))
	unlocked_units = player_data.get("unlocked_units", unlocked_units)
	unlocked_traps = player_data.get("unlocked_traps", unlocked_traps)
	unlocked_fields = player_data.get("unlocked_fields", unlocked_fields)
	unit_inventory = player_data.get("unit_inventory", unit_inventory)
	traps_inventory = player_data.get("traps_inventory", traps_inventory)
	fields_inventory = player_data.get("fields_inventory", fields_inventory)

func is_unit_unlocked(unit: String):
	return unit in unlocked_units

func get_unit_amount(unit: String):
	if not unit in unit_inventory:
		return 0
	return int(unit_inventory[unit])

func add_unit(unit: String):
	if not unit in unit_inventory:
		unit_inventory[unit] = 0
	unit_inventory[unit] += 1
	return int(unit_inventory[unit])

func remove_unit(unit: String):
	if not unit in unit_inventory:
		print(unit, " isn't in inventory")
		return
	if unit_inventory[unit] <= 0:
		unit_inventory.erase(unit)
		print("Not enough of ", unit)
		return
	unit_inventory[unit] -= 1
	var result = unit_inventory[unit]
	if unit_inventory[unit] <= 0:
		unit_inventory.erase(unit)
		result = 0
	return int(result)

func unlock_unit(unit: String):
	if unit in unlocked_units:
		print(unit, " is already unlocked")
		return
	unlocked_units.append(unit)
	return true

func is_trap_unlocked(trap: String):
	return trap in unlocked_traps

func get_trap_amount(trap: String):
	if not trap in traps_inventory:
		return 0
	return int(traps_inventory[trap])

func add_trap(trap: String):
	if not trap in traps_inventory:
		traps_inventory[trap] = 0
	traps_inventory[trap] += 1
	return int(traps_inventory[trap])

func remove_trap(trap: String):
	if not trap in traps_inventory:
		print(trap, " isn't in inventory")
		return
	if traps_inventory[trap] <= 0:
		traps_inventory.erase(trap)
		print("Not enough of ", trap)
		return
	traps_inventory[trap] -= 1
	var result = traps_inventory[trap]
	if traps_inventory[trap] <= 0:
		traps_inventory.erase(trap)
		result = 0
	return int(result)

func unlock_trap(trap: String):
	if trap in unlocked_traps:
		print(trap, " is already unlocked")
		return
	unlocked_traps.append(trap)
	return true

func is_field_unlocked(field: String):
	return field in unlocked_fields

func get_field_amount(field: String):
	if not field in fields_inventory:
		return 0
	return int(fields_inventory[field])

func add_field(field: String):
	if not field in fields_inventory:
		fields_inventory[field] = 0
	fields_inventory[field] += 1
	return int(fields_inventory[field])

func remove_field(field: String):
	if not field in fields_inventory:
		print(field, " isn't in inventory")
		return
	if fields_inventory[field] <= 0:
		fields_inventory.erase(field)
		print("Not enough of ", field)
		return
	fields_inventory[field] -= 1
	var result = fields_inventory[field]
	if fields_inventory[field] <= 0:
		fields_inventory.erase(field)
		result = 0
	return int(result)

func unlock_field(field: String):
	if field in unlocked_fields:
		print(field, " is already unlocked")
		return
	unlocked_fields.append(field)
	return true

func update_souls_ui():
	SoulsHud.get_node("Amount").text = str(souls)

func add_souls(amount: int):
	souls += amount
	update_souls_ui()

func remove_souls(amount: int):
	if amount > souls:
		print(amount, " is too many, player only has ", souls)
		return
	souls -= amount
	update_souls_ui()
	return true

func get_save_data() -> Dictionary:
	return {
		"souls": souls,
		"unlocked_units": unlocked_units.duplicate(),
		"unlocked_traps": unlocked_traps.duplicate(),
		"unlocked_fields": unlocked_fields.duplicate(),
		"unit_inventory": unit_inventory.duplicate(),
		"traps_inventory": traps_inventory.duplicate(),
		"fields_inventory": fields_inventory.duplicate(),
	}

func load_save_data(data: Dictionary) -> void:
	souls = data.get("souls", souls)
	unlocked_units = data.get("unlocked_units", unlocked_units)
	unlocked_traps = data.get("unlocked_traps", unlocked_traps)
	unlocked_fields = data.get("unlocked_fields", unlocked_fields)
	unit_inventory = data.get("unit_inventory", unit_inventory)
	traps_inventory = data.get("traps_inventory", traps_inventory)
	fields_inventory = data.get("fields_inventory", fields_inventory)
	update_souls_ui()

func save_state():
	_saved_state = get_save_data()

func restore_state():
	if _saved_state == null:
		print("No saved state to restore")
		return
	load_save_data(_saved_state)

func has_saved_state() -> bool:
	return _saved_state != null
