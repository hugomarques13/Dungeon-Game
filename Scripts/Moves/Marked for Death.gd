extends Node2D

var cooldown := 4
var current_cooldown := 0
var damage: float = 10
var status_amount = 99

var description = "Inflict Every debuff."

@onready var character = $"../.."

func use(target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	
	await VisualsHandler.make_visual(target, "Debuff")
	
	if not target:
		return
	
	DamageHandler.do_damage(character, target, damage, {"Bleed": status_amount,"Weakened": status_amount, "Burn": status_amount, "Mark": status_amount})
	
	return
