extends Node2D

var cooldown := 8
var current_cooldown := 0

const damage = 50
const hit_amount = 3

var description = "\"A concentrated negative energy that can be hurled at your oppenents.\""

@onready var character = $"../.."

func use(target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	if not target:
		print("no target!")
		return
	
	for i in range(hit_amount):
		
		await VisualsHandler.make_visual(target, "Magic")
		
		DamageHandler.do_damage(character, target, damage, {})
	
	return
