extends Node2D

var cooldown := 2
var current_cooldown := 0
var is_aoe = true

const damage = 30

var description = "Swipe at them with your tail, dealing medium damage to all enemies."

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	var targets = TargetGetter.get_aoe_enemy_targets(character)
	
	await VisualsHandler.make_visual_multi(targets, "Blunt")
	
	for target in targets:
	
		DamageHandler.do_damage(character, target, damage, {})
	
	return
