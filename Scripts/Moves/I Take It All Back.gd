extends Node2D

var cooldown := 4
var current_cooldown := 0
var has_no_target = true

const status_amount = 99

var description = "All magic has a cost, sacrifice a quarter of your health to empower yourself."

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	VisualsHandler.make_visual(character, "Buff")
	await VisualsHandler.make_visual(character, "Heal")
	
	character.take_damage(-999999999)
	
	StatusHandler.apply_status(character, "Powerful", status_amount)
	StatusHandler.apply_status(character, "Riposte", status_amount)
	StatusHandler.apply_status(character, "Tango", status_amount)
	
	return
