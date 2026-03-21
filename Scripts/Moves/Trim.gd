extends Node2D

var cooldown := 3
var current_cooldown := 0
var has_no_target = true

const damage = 40
const status_amount = 4

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
	
	await VisualsHandler.make_visual(target, "Magic")
	
	DamageHandler.do_damage(character, target, damage, {"Bleed": status_amount})
	
	return
