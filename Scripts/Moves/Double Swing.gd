extends Node2D

var cooldown := 3
var current_cooldown := 0

const damage = 20

var description = "Swing quickly with both arms, dealing low damage twice to a target."

@onready var character = $"../.."

func use(target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	if not target:
		print("no target!")
		return
	
	for i in range(2):
		
		print("used basic attack!")
		
		await VisualsHandler.make_visual(target, "Blunt")
		
		DamageHandler.do_damage(character, target, damage, {})
	
	return
