extends Node2D

var cooldown := 5
var current_cooldown := 0
var has_no_target = true

const status_amount = 3

var description = "Enter Riposte Stance, giving you a chance to counter when hit."

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	await VisualsHandler.make_visual(character, "Buff")
	
	StatusHandler.apply_status(character, "Riposte", status_amount)
	
	return
