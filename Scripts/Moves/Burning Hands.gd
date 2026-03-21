extends Node2D

var cooldown := 4
var current_cooldown := 0
var has_no_target = true
var is_aoe = true

const damage = 40
const status_amount = 3

var description = "TO DO"

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
