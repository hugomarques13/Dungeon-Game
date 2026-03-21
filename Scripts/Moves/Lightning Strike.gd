extends Node2D

var cooldown := 6
var current_cooldown := 0
var has_no_target = true
var is_aoe = true

const damage = 30
const status_amount = 1
const STATUS_CHANCE = 10

var description = "TO DO"

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	var targets = TargetGetter.get_aoe_enemy_targets(character)
	
	var status = {"Stun": status_amount}
	
	await VisualsHandler.make_visual_multi(targets, "Dark")
	
	for target in targets:
		
		if randi_range(1,100) <= STATUS_CHANCE:
			DamageHandler.do_damage(character, target, damage, status)
		else:
			DamageHandler.do_damage(character, target, damage, {})
	
	return
