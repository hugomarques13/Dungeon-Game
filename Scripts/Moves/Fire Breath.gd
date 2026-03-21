extends Node2D

var cooldown := 3
var current_cooldown := 0
var is_aoe = true
var status_amount = 4

const damage = 50

var description = "Breathe fire on these puny invaders, dealing medium and burn to all enemies."

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	var targets = TargetGetter.get_aoe_enemy_targets(character)
	
	await VisualsHandler.make_visual_multi(targets, "Fire")
	
	for target in targets:
	
		DamageHandler.do_damage(character, target, damage, {"Burn": status_amount})
	
	return
