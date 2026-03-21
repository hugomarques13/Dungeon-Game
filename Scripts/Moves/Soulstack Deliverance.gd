extends Node2D

var cooldown := 1
var current_cooldown := 0
var is_aoe = true

var description = "Reap their soul. Triple the earnings for the Reaper."

@onready var character = $"../.."
@onready var Player = $"../../../../../Player"

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	var damage = Player.souls
	
	var targets = TargetGetter.get_aoe_enemy_targets(character)
	
	Player.remove_souls(Player.souls)
	
	await VisualsHandler.make_visual_multi(targets, "Dark")
	
	for target in targets:
	
		DamageHandler.do_damage(character, target, damage, {})
		
	
	return
