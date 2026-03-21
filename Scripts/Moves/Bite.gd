extends Node2D

var cooldown := 3
var current_cooldown := 0

const damage = 25

var description = "A fast bite that deals low damage to a target."

@onready var character = $"../.."

func use(target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	if not target:
		print("no target!")
		return
	
	await VisualsHandler.make_visual(target, "DarkBite")
	
	DamageHandler.do_damage(character, target, damage, {})
	
	return
