extends Node2D

var cooldown := 4
var current_cooldown := 0
var is_aoe = true

const damage = 20

var description = "Cleave through the enemies, dealing medium damage to all targets."

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	print("used basic attack!")
	
	var targets = TargetGetter.get_aoe_enemy_targets(character)
	
	await VisualsHandler.make_visual_multi(targets, "Slash")
	
	for target in targets:
	
		DamageHandler.do_damage(character, target, damage, {})
	
	return
