extends Node2D

@onready var SoulsHud = $"../HUD/Souls"

var unlocked_units = [
	"Lesser Zombie"
]

var unit_inventory: Dictionary[String, int] = {}
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
