extends Node2D

var cooldown := 5
var current_cooldown := 0

const damage = 999996
const MULTIPLIER = 3

var description = "Reap the target's soul, dealing low damage, if this attack kills the enemy, more souls are extracted."

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
	
	await VisualsHandler.make_visual(target, "Dark")
	
	DamageHandler.do_damage(character, target, damage, {}, MULTIPLIER)

	return
