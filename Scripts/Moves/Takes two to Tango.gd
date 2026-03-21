extends Node2D

var cooldown := 6
var current_cooldown := 0
var has_no_target = true

const status_amount = 4

var description = "Dance to your heart's content, severely increasing your evasiveness."

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	await VisualsHandler.make_visual(character, "Buff")
	
	StatusHandler.apply_status(character, "Tango", status_amount)
	
	return
