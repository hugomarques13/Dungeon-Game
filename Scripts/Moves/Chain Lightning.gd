extends Node2D

var cooldown := 5
var current_cooldown := 0

const damage = 20
const chain_amount = 5
var has_no_target = true

var description = "Lightning that chains 5 times dealing low damage each time."

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	var targets = TargetGetter.get_chain_targets(character, chain_amount)
	
	if not targets:
		print("no target!")
		return
	
	for target in targets:
		await VisualsHandler.make_visual(target, "Dark")
		DamageHandler.do_damage(character, target, damage, {})
	
	return
