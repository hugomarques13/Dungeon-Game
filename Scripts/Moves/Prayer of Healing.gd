extends Node2D
var cooldown := 5
var current_cooldown := 0

var description = "TO DO"

var has_no_target = true

@onready var character = $"../.."

func use(_false_target):
	if current_cooldown > 0:
		return
		
	await VisualsHandler.make_visual(character, "Buff")
	
	print("Prayer of Healing primed")
	StatusHandler.apply_status(character, "Prayer of Healing", 1)
	
	return
