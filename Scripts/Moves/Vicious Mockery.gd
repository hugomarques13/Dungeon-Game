extends Node2D

var cooldown := 3
var current_cooldown := 0
var damage: float = 10
var status_amount = 3

var description = "Question their life choices, dealing low damage and weakening a target."

@onready var character = $"../.."

func use(target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	await VisualsHandler.make_visual(target, "Dark")
	
	if not target:
		return
	
	DamageHandler.do_damage(character, target, damage, {"Weakened": status_amount})
	
	VisualsHandler.make_visual(target, "Debuff")
	
	return
