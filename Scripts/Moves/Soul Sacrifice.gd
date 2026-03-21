extends Node2D

var cooldown := 4
var current_cooldown := 0
var has_no_target = true
var health_cost_percentage = 0.25

const status_amount = 4

var description = "All magic has a cost, sacrifice a quarter of your health to empower yourself."

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	await VisualsHandler.make_visual(character, "Dark")
		
	var damage = character.max_health * 0.25
	
	if character.health - damage <= 0:
		damage = character.health - 1
		
	await VisualsHandler.make_visual(character, "Buff")
	
	character.take_damage(damage)
	
	StatusHandler.apply_status(character, "Powerful", status_amount)
	
	return
