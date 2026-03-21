extends Node2D
var cooldown := 99
var current_cooldown := 0


var description = "Eat your zombie caretaker, at the start of your next turn, deal extreme damage to all enemies, applying burn but dying."
var has_no_target = true


@onready var character = $"../.."

func use(_false_target):
	if current_cooldown > 0:
		return
		
	await VisualsHandler.make_visual(character, "Bite")
	
	print("Flaming Munchies primed")
	StatusHandler.apply_status(character, "Flaming Munchies", 1)
	
	return
