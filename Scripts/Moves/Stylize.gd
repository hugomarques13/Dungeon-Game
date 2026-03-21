extends Node2D

var cooldown := 3
var current_cooldown := 0
var has_no_target = true

const status_amount = 4

var description = "TO DO"

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	var target = TargetGetter.get_random_single_ally_target(character)
	
	if not target:
		return
	
	await VisualsHandler.make_visual(character, "Buff")
	
	StatusHandler.apply_status(character, "Powerful", status_amount)
	
	return
