extends Node2D

var cooldown := 2
var current_cooldown := 0
var damage: float = 10

@onready var character = $"../.."

func use():
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	print("used move!")
	
	await get_tree().create_timer(0.5).timeout
	
	var target = TargetGetter.get_random_single_enemy_target(character)
	
	if not target:
		return
	
	target.take_damage(damage)
	
	return
