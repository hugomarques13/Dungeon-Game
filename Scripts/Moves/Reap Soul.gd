extends Node2D

var cooldown := 2
var current_cooldown := 0

const damage = 15
const MULTIPLIER = 1.5

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
	
	await VisualsHandler.make_visual(target, "Slash")
	
	DamageHandler.do_damage(character, target, damage, {}, MULTIPLIER)

	return
