extends Node2D

var cooldown := 99
var current_cooldown := 0

const damage = 99999999

var description = "TO DO"

@onready var character = $"../.."
@onready var enemy_manager = $"../../../../../Chibis"

var ending_scene = preload("res://Scenes/Ending.tscn")

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
	
	var targets = TargetGetter.get_aoe_enemy_targets(character)
	
	await VisualsHandler.make_visual_multi(targets, "Dark")
	
	for target in targets:
		target.take_damage(damage)
	
	enemy_manager._exit_tree()
	
	await get_tree().process_frame
	
	get_tree().change_scene_to_packed(ending_scene)
	
	
	return
