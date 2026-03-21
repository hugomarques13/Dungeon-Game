extends Node2D

var cooldown := 3
var current_cooldown := 0
var is_aoe = true
var status_amount = 2

const damage = 20

var description = "This zombie flesh isn't good for your stomach, barf on all enemies, dealing low damage and burning them."

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
