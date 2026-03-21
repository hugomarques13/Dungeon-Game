extends Node2D

var cooldown := 5
var current_cooldown := 0
var has_no_target = true
var is_aoe = true

const status_amount = 2

var description = "TO DO"

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	var targets = TargetGetter.get_aoe_ally_targets(character)
	
	await VisualsHandler.make_visual_multi(targets, "Buff")
	
	for target in targets:
	
		StatusHandler.apply_status(target, "Powerful", status_amount)
	
	return
