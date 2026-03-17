extends Node2D

var cooldown := 5
var current_cooldown := 0
var status_amount = 3

var description = "TO DO"

@onready var character = $"../.."

func use(target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	print("used move!")
	
	await get_tree().create_timer(0.5).timeout
	
	if not target:
		return

	StatusHandler.apply_status(target, "Mark", status_amount)
	
	return
