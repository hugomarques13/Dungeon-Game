extends Node2D

var cooldown := 6
var current_cooldown := 0
var has_no_target = true

const status_amount = 4

var description = "TO DO"

@onready var character = $"../.."

func use(false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	StatusHandler.apply_status(character, "Tango", status_amount)
	
	return
