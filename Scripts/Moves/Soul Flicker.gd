extends Node2D

var cooldown := 99
var current_cooldown := 0
var has_no_target = true
var is_aoe = true

const damage = 25

var description = "TO DO"

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	var targets = TargetGetter.get_aoe_enemy_targets(character)
	
	for i in range(3):
	
		VisualsHandler.make_visual_multi(targets, "Dark")
		
		await get_tree().create_timer(0.2).timeout
		
		for target in targets:
		
			DamageHandler.do_damage(character, target, damage, {})
	
	return
