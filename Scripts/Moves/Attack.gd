extends Node2D

var cooldown := 0
var current_cooldown := 0

@onready var character = $"../.."

func use(target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	if not target:
		target = TargetGetter.get_random_single_enemy_target(character)
		if not target:
			print("no target even after re picking")
			return
	
	for i in range(character.base_attack_amount):
		
		print("used basic attack!")
		
		var damage = character.base_attack_damage
		
		await VisualsHandler.make_visual(target, character.base_attack_effect)
		
		DamageHandler.do_damage(character, target, damage, {})
	
	return
