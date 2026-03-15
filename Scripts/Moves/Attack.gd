extends Node2D

var cooldown := 0
var current_cooldown := 0
var damage: float = 10

@onready var character = $"../.."

func use(target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	if not target:
		print("no target!")
		return
		
	print("used move!")
	
	await get_tree().create_timer(0.5).timeout
	
	target.take_damage(damage)
	
	return
