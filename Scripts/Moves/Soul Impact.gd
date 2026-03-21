extends Node2D

var cooldown := 99
var current_cooldown := 0

const status_amount = 1

const damage = 65

var description = "TO DO"

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	var target = TargetGetter.get_random_single_enemy_target(character)
	
	if not target:
		return
	
	await VisualsHandler.make_visual(target, "Fire")
	
	DamageHandler.do_damage(character, target, damage, {"Burn": status_amount})
	
	return
