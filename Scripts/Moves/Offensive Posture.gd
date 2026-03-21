extends Node2D

var cooldown := 6
var current_cooldown := 0
var has_no_target = true

var description = "TO DO"

const status_amount = 4

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	await VisualsHandler.make_visual(character, "Buff")
	
	StatusHandler.apply_status(character, "Readied", status_amount)
	
	return
