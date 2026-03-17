extends Node2D

var cooldown := 5
var current_cooldown := 0
var has_no_target = true

var description = "TO DO"

const status_amount = 3

@onready var character = $"../.."

func use(false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	StatusHandler.apply_status(character, "Taunt", status_amount)
	
	return
