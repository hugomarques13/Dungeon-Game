extends Node2D

@onready var Allies = $Allies
@onready var Enemies = $Enemies
@onready var HUD = $HUD

var turn_order = []
var turn_taken = []
var current_round = 0
var current_character = null

func _ready() -> void:
	TargetGetter.Allies = Allies
	TargetGetter.Enemies = Enemies
	
	for character in Allies.get_children():
		turn_order.append(character)
		
	for character in Enemies.get_children():
		turn_order.append(character)
		
	start_round()

func perform_turn(character: CharacterBody2D):
	print(character.name, " is taking their turn")
	var moves = character.get_node_or_null("Moves")
	
	current_character = character
	
	if moves:
		lower_cooldowns(moves)
	
	if character.get_parent() == Allies:
		var result = await handle_player_turn(character)
		if not result:
			return
	else:
		await handle_ai_turn(character)
	
	end_turn(character)

func end_turn(character: CharacterBody2D):
	clean_old_moves()
	turn_taken.append(character)
	turn_order.remove_at(0)
	
	current_character = null
	
	await get_tree().create_timer(0.2).timeout
	
	next_turn()

func next_turn():
	if turn_order == []:
		start_round()
		return
		
	perform_turn(turn_order[0])

func start_round():
	if current_round != 0:
		turn_order = turn_taken.duplicate()
		turn_taken = []
	current_round += 1
	
	print("\nStarting round number ", current_round, "\n")
	
	next_turn()
	
func use_move(move):
	await move.use()
	move.current_cooldown = move.cooldown
	
	return
	
func select_move(moves):
	var possible_moves = []
	
	for move in moves.get_children():
		if move.current_cooldown > 0:
			continue
			
		possible_moves.append(move)
		
	if possible_moves == []:
		return null
		
	possible_moves.shuffle()
	
	return possible_moves[0]
	
func lower_cooldowns(moves):
	for move in moves.get_children():
		if move.current_cooldown <= 0:
			continue
			
		move.current_cooldown -= 1
		
func handle_ai_turn(character):
	var moves = character.get_node_or_null("Moves")
	
	await get_tree().create_timer(1).timeout

	if moves:
		var move_to_use = select_move(moves)
		if move_to_use:
			use_move(move_to_use)
			
	return true

func handle_player_turn(character):
	var moves = character.get_node_or_null("Moves")
	
	clean_old_moves()
	
	var container = HUD.get_node("GridContainer")
	var template = HUD.get_node("GridContainer/Template")
	
	for move in moves.get_children():
		var newMoveIcon = template.duplicate()
		newMoveIcon.text = move.name
		newMoveIcon.name = move.name
		newMoveIcon.visible = true
		newMoveIcon.disabled = move.current_cooldown > 0
		
		container.add_child(newMoveIcon)
		
	var old_round = current_round
		
	await get_tree().create_timer(10).timeout
	
	if not (current_character == character and old_round == current_round):
		return false
		
	return true
		
func clean_old_moves():
	var container = HUD.get_node("GridContainer")
	
	for move in container.get_children():
		if move.name != "Template":
			move.queue_free()

func character_died(character):
	if current_character == character:
		end_turn(character)
	
	if character in turn_order:
		turn_order.remove_at(turn_order.find(character))
		
	if character in turn_taken:
		turn_taken.remove_at(turn_taken.find(character))

func move_button_pressed(name):
	var moves = current_character.get_node_or_null("Moves")
	
	if not moves:
		return
	
	var move = moves.get_node_or_null(NodePath(name))
	if not move:
		return
		
	await use_move(move)
	
	end_turn(current_character)
