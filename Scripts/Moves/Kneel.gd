extends Node2D

var cooldown := 99
var current_cooldown := 0
var has_no_target = true
var is_aoe = true

const damage = 0

var description = "TO DO"

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	var targets = TargetGetter.get_aoe_enemy_targets(character)
	
	await VisualsHandler.make_visual_multi(targets, "Debuff")
		
	for target in targets:
	
		StatusHandler.apply_status(target, "Weakened", 99)
		StatusHandler.apply_status(target, "Stun", 1)
	
	return
