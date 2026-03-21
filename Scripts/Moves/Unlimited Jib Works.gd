extends Node2D

var cooldown := 6
var current_cooldown := 0
var has_no_target = true

const damage = 10

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
	
	for i in range(10):
		
		await get_tree().create_timer(0.05).timeout
		
		VisualsHandler.make_visual(target, "Slash")
		
		target = TargetGetter.get_random_single_enemy_target(character)
		
		DamageHandler.do_damage(character, target, damage, {"Bleed": 1})
	
	return
