extends Node2D

var cooldown := 2
var current_cooldown := 0
var damage: float = 10
var burn_amount = 2
var has_no_target = true
var description = "A move that applies burn"

@onready var character = $"../.."

func use(false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	print("used move!")
	
	await get_tree().create_timer(0.5).timeout
	
	var target = TargetGetter.get_random_single_enemy_target(character)
	
	if not target:
		return
	
	DamageHandler.do_damage(character, target, damage, {"Burn": burn_amount})
	
	return
