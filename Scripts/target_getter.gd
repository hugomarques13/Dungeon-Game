extends Node

var Allies
var Enemies

func get_random_single_enemy_target(character):
	var where_to_get = Allies
	
	if character.get_parent() == Allies:
		where_to_get = Enemies
		
	var possible_targets = []
	
	# done like this so we can filter out specific ppl later
	for eligible_character in where_to_get.get_children():
		possible_targets.append(eligible_character)
		
	if possible_targets == []:
		return null
		
	possible_targets.shuffle()
	
	return possible_targets[0]
	
