extends Node2D

var cooldown := 2
var current_cooldown := 0

const damage = 15

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
		
	print("used basic attack!")
	
	await get_tree().create_timer(0.5).timeout
	
	DamageHandler.do_damage(character, target, damage, {})

	return
