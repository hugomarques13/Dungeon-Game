extends Node2D

var cooldown := 4
var current_cooldown := 0
var has_no_target = true

var description = "Summon a skeleton on an empty spot, will fail if there are no slots available."

@onready var character = $"../.."
@onready var CombatManager = $"../../../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	print("used move!")
	
	await get_tree().create_timer(0.5).timeout
	
	var target = TargetGetter.get_random_empty_ally_slot(character)
	
	if not target:
		return
		
	CombatManager.summon_character("Skeleton", target, character)
	# summon skeleton
	
	return
