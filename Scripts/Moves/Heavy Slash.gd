extends Node2D

var cooldown := 4
var current_cooldown := 0

const damage = 50

var description = "Swing down with your sword, dealing medium damage to a target."

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
	
	DamageHandler.do_damage(character, target, damage, {})
	
	return
