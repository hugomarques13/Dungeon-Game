extends Node2D

var cooldown := 3
var current_cooldown := 0
var is_aoe = true

var description = "Throw a bone at all enemies, dealing low damage."

const damage = 20

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	print("used basic attack!")
	
	var targets = TargetGetter.get_aoe_enemy_targets(character)
	
	await VisualsHandler.make_visual_multi(targets, "Blunt")
	
	for target in targets:
	
		DamageHandler.do_damage(character, target, damage, {})
	
	return
