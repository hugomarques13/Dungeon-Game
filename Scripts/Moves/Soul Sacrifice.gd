extends Node2D

var cooldown := 4
var current_cooldown := 0
var has_no_target = true
var health_cost_percentage = 0.25

const status_amount = 4

var description = "TO DO"

@onready var character = $"../.."

func use(false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	var damage = character.max_health * 0.25
	
	character.take_damage(damage)
	
	StatusHandler.apply_status(character, "Powerful", status_amount)
	
	return
