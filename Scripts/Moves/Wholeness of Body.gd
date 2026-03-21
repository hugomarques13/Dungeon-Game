extends Node2D

var cooldown := 8
var current_cooldown := 0
var has_no_target = true

const heal_percentage = 0.25

var description = "TO DO"

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	await VisualsHandler.make_visual(character, "Heal")
	
	character.take_damage(-character.max_health*0.25)
	
	return
