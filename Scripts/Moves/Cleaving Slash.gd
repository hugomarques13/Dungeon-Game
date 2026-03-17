extends Node2D

var cooldown := 4
var current_cooldown := 0
var is_aoe = true

const damage = 30

var description = "TO DO"

@onready var character = $"../.."

func use(false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	print("used basic attack!")
	
	var targets = TargetGetter.get_aoe_enemy_targets(character)
	
	for target in targets:
	
		DamageHandler.do_damage(character, target, damage, {})
	
	return
