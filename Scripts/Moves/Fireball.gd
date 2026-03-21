extends Node2D

var cooldown := 5
var current_cooldown := 0
var hits_all_except_self = true
var status_amount = 3

const damage = 40

var description = "I didn't ask how small the room was, deals medium damage and burning everyone except yourself."

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	print("used basic attack!")
	
	var targets = TargetGetter.get_all_targets_except_character(character)
	
	await VisualsHandler.make_visual_multi(targets, "Burn")
	
	for target in targets:
		DamageHandler.do_damage(character, target, damage, {"Burn": status_amount})
	
	return
