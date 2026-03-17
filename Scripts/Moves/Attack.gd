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
		print("no target!")
		return
	
	for i in range(character.base_attack_amount):
		
		print("used basic attack!")
		
		var damage = character.base_attack_damage
		
		await get_tree().create_timer(0.5).timeout
		
		DamageHandler.do_damage(character, target, damage, {})
	
	return
