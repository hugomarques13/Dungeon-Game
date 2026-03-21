extends Node2D

var cooldown := 4
var current_cooldown := 0
const status_amount = 5
var has_no_target = true

const damage = 85

var description = "TO DO"

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	var target = TargetGetter.get_random_single_enemy_target(character)
	
	if not target:
		return
	
	await VisualsHandler.make_visual(target, "Slash")
	VisualsHandler.make_visual(character, "Debuff")
	
	DamageHandler.do_damage(character, target, damage, {})
	StatusHandler.apply_status(character, "Weakened", status_amount)
	
	return
