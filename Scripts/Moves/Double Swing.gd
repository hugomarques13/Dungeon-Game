extends Node2D

var cooldown := 3
var current_cooldown := 0

const damage = 20

var description = "TO DO"

@onready var character = $"../.."

func use(target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	if not target:
		print("no target!")
		return
	
	for i in range(2):
		
		print("used basic attack!")
		
		await get_tree().create_timer(0.5).timeout
		
		DamageHandler.do_damage(character, target, damage, {})
	
	return
