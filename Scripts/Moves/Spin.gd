extends Node2D

var cooldown := 3
var current_cooldown := 0

const damage = 15
const hit_amount = 3

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
	
	for i in range(hit_amount): 
		
		await get_tree().create_timer(0.1).timeout
		
		VisualsHandler.make_visual(target, "Slash")
		
		DamageHandler.do_damage(character, target, damage, {})
	
	return
