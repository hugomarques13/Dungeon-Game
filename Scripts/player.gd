extends Node2D

@onready var SoulsHud = $"../HUD/Souls"

var unlocked_units = [
	"Lesser Zombie"
]

var unlocked_traps = []

var unit_inventory: Dictionary[String, int] = {}
var traps_inventory: Dictionary[String, int] = {}
var souls = 1000

func _ready():
	update_souls_ui()

func is_unit_unlocked(unit: String):
	return unit in unlocked_units
	
func get_unit_amount(unit: String):
	if not unit in unit_inventory:
		return 0
	
	return unit_inventory[unit]
	
func add_unit(unit: String):
	if not unit in unit_inventory:
		unit_inventory[unit] = 0
		
	unit_inventory[unit] += 1
	
	return unit_inventory[unit]

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
		
	return result

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
	return traps_inventory[trap]

func add_trap(trap: String):
	if not trap in traps_inventory:
		traps_inventory[trap] = 0
	traps_inventory[trap] += 1
	return traps_inventory[trap]

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
	
	return result

func unlock_trap(trap: String):
	if trap in unlocked_traps:
		print(trap, " is already unlocked")
		return
	unlocked_traps.append(trap)
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
