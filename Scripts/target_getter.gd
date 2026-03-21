extends Node

var Allies
var Enemies
var AllyPositions
var EnemyPositions

func get_random_single_enemy_target(character):
	var where_to_get = Allies
	
	if character.get_parent() == Allies:
		where_to_get = Enemies
	
	var possible_targets = []
	
	for eligible_character in where_to_get.get_children():
		possible_targets.append(eligible_character)
	
	if possible_targets == []:
		return null
	
	possible_targets = _filter_for_taunt(possible_targets)
	possible_targets.shuffle()
	
	return possible_targets[0]

func get_random_single_ally_target(character):
	var where_to_get = Allies
	
	if character.get_parent() == Enemies:
		where_to_get = Enemies
	
	var possible_targets = []
	
	for eligible_character in where_to_get.get_children():
		possible_targets.append(eligible_character)
	
	if possible_targets == []:
		return null
	
	possible_targets.shuffle()
	
	return possible_targets[0]

func get_random_empty_ally_slot(character):
	var where_to_get = Allies
	var positions_to_check = AllyPositions
	
	if character.get_parent() == Enemies:
		where_to_get = Enemies
		positions_to_check = EnemyPositions
	
	var occupied_positions = []
	for member in where_to_get.get_children():
		for i in range(positions_to_check.size()):
			if member.global_position == positions_to_check[i].global_position:
				occupied_positions.append(i + 1)
				break
	
	var empty_slots = []
	for i in range(positions_to_check.size()):
		if not (i + 1) in occupied_positions:
			empty_slots.append(i + 1)
	
	if empty_slots.is_empty():
		return null
	
	empty_slots.shuffle()
	return empty_slots[0]

func get_aoe_enemy_targets(character):
	var where_to_get = Allies
	
	if character.get_parent() == Allies:
		where_to_get = Enemies
		
	var targets = []
	for eligible_character in where_to_get.get_children():
		targets.append(eligible_character)
		
	return targets
	
func get_aoe_ally_targets(character):
	var where_to_get = Allies
	
	if character.get_parent() == Enemies:
		where_to_get = Enemies
	
	var targets = []
	for eligible_character in where_to_get.get_children():
		targets.append(eligible_character)
		
	return targets
	
func get_all_targets_except_character(character):
	var targets = []
	
	for eligible_character in Allies.get_children():
		targets.append(eligible_character)
		
	for eligible_character in Enemies.get_children():
		targets.append(eligible_character)
		
	targets.erase(character)
	
	return targets
	
func get_chain_targets(character, chains: int):
	var where_to_get = Enemies
	
	if character.get_parent() == Enemies:
		where_to_get = Allies
	
	var living = where_to_get.get_children().filter(func(e): return not e.is_dead)
	
	if living.is_empty():
		return []
	
	var targets = []
	
	var taunted = _filter_for_taunt(living)
	taunted.shuffle()
	targets.append(taunted[0])
	
	for i in range(chains - 1):
		var last = targets[-1]
		var options = living.filter(func(e): return e != last)
		
		if options.is_empty():
			break
		
		options.shuffle()
		targets.append(options[0])
	
	return targets
	
func _filter_for_taunt(targets: Array) -> Array:
	var taunting = targets.filter(func(e):
		return e.get_node_or_null("Status") and e.get_node("Status").get_node_or_null("Taunt")
	)
	return taunting if not taunting.is_empty() else targets
