extends Node2D

var cooldown := 5
var current_cooldown := 0
var has_no_target = true
var is_aoe = true

const damage = 50

var description = "TO DO"

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	var targets = TargetGetter.get_aoe_enemy_targets(character)
	
	await VisualsHandler.make_visual_multi(targets, "Magic")
	
	for target in targets:
	
		DamageHandler.do_damage(character, target, damage, {})
	
	return
