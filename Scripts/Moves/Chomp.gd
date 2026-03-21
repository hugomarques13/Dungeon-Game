extends Node2D

var cooldown := 6
var current_cooldown := 0

const damage = 999

var description = "Devour a fool, just be careful to chew."

@onready var character = $"../.."

func use(target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	if not target:
		print("no target!")
		return
	
	await VisualsHandler.make_visual(target, "Bite")
	
	DamageHandler.do_damage(character, target, damage, {})
	
	return
