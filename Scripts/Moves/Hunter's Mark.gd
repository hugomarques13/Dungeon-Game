extends Node2D

var cooldown := 5
var current_cooldown := 0
var status_amount = 3

var description = "Mark a target, causing them to take more damage when hit."

@onready var character = $"../.."

func use(target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	print("used move!")
	
	await VisualsHandler.make_visual(target, "Debuff")
	
	if not target:
		return

	StatusHandler.apply_status(target, "Mark", status_amount)
	
	return
