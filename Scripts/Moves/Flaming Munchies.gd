extends Node2D
var cooldown := 99
var current_cooldown := 0


var description = "TO DO"
var has_no_target = true


@onready var character = $"../.."

func use(false_target):
	if current_cooldown > 0:
		return
	
	print("Flaming Munchies primed")
	StatusHandler.apply_status(character, "Flaming Munchies", 1)
	
	return
