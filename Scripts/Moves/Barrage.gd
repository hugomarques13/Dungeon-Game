extends Node2D

var cooldown := 4
var current_cooldown := 0

const damage = 15

var description = "A barrage of shots, dealing low damage 5 times to a target."

@onready var character = $"../.."

func use(target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	if not target:
		print("no target!")
		return
	
	for i in range(5):
		
		print("used basic attack!")
		
		await get_tree().create_timer(0.1).timeout
		VisualsHandler.make_visual(target, "Blunt")
		
		DamageHandler.do_damage(character, target, damage, {})
	
	return
