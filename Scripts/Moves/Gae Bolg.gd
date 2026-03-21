extends Node2D

var cooldown := 99
var current_cooldown := 0
var has_no_target = true
var is_aoe = true

const damage = 99

var description = "TO DO"

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	print("used basic attack!")
	
	var targets = TargetGetter.get_aoe_enemy_targets(character)
	
	await VisualsHandler.make_visual_multi(targets, "Magic")
	
	for target in targets:
	
		DamageHandler.do_damage(character, target, damage, {})
	
	await get_tree().create_timer(0.1).timeout
	
	DamageHandler.do_damage(character, character, 999, {})
	
	return
