extends Node2D

const BURN_DAMAGE = 10

@onready var Allies = $Allies
@onready var Enemies = $Enemies
@onready var HUD = $HUD
@onready var Buttons = $HUD/Buttons
@onready var SkillsMenu = $HUD/SkillsMenu
@onready var SkillsContainer = $HUD/SkillsMenu/GridContainer
@onready var SkillTemplate = $HUD/SkillsMenu/GridContainer/Template
@onready var Description = $HUD/SkillsMenu/Description
@onready var AllyPositions = [
	$Slots/Allies/Slot1,
	$Slots/Allies/Slot2,
	$Slots/Allies/Slot3,
	$Slots/Allies/Slot4
]
@onready var EnemyPosition = [
	$Slots/Enemies/Slot1,
	$Slots/Enemies/Slot2,
	$Slots/Enemies/Slot3,
	$Slots/Enemies/Slot4
]
@onready var RegularHUD = $"../HUD"
@onready var EnemyChibis = $"../Chibis"
@onready var FloorUI = $"../HUD/FloorUI"


var Floors = []

var turn_order = []
var turn_taken = []
var current_round = 0
var current_character = null

var selected_move = null
var current_target = null
var current_action = null

var is_fighting = false

var ally_scenes = {}
var enemy_scenes = {}

var HUD_visibility = {}

func _ready() -> void:
	await get_tree().process_frame
	Floors = FloorUI.floors
	TargetGetter.Allies = Allies
	TargetGetter.Enemies = Enemies
	
	load_assets("res://Prefabs/Allies/", ally_scenes)
	load_assets("res://Prefabs/Enemies/", enemy_scenes)

func new_combat(allies_dict, enemies_dict, enemies_info):
	print("New combat started with ", allies_dict, "\n", enemies_dict, "\n", enemies_info)
	for pos in allies_dict.keys():
		var ally = allies_dict[pos]
		
		if not ally:
			continue
		
		var character = ally_scenes[ally].instantiate()
		
		print("Added ally ", character)
		Allies.add_child(character)
		
		character.global_position = AllyPositions[pos-1].global_position
	
	for pos in enemies_dict.keys():
		var enemy = enemies_dict[pos]
		
		if not enemy:
			continue
		
		var character = enemy_scenes[enemy].instantiate()
		
		print("Added enemy ", character)
		Enemies.add_child(character)
		
		character.global_position = EnemyPosition[pos-1].global_position
		
		if pos in enemies_info and enemies_info[pos] != null:
			character.health = enemies_info[pos].health
			character.update_hp_bar()
		
	
	start_combat()

func start_combat():
	position = Floors[FloorUI.current_floor].position
	
	visible = true
	HUD.visible = true
	disable_regular_hud()
	is_fighting = true
	
	for character in Allies.get_children():
		turn_order.append(character)
	
	for character in Enemies.get_children():
		turn_order.append(character)
	
	start_round()

func disable_regular_hud():
	HUD_visibility = {}
	for hud_item in RegularHUD.get_children():
		if hud_item.name != "Souls":
			HUD_visibility[hud_item] = hud_item.visible
			hud_item.visible = false

func reenable_regular_hud():
	for hud_item in HUD_visibility.keys():
			hud_item.visible = HUD_visibility[hud_item]

func load_assets(folder_path: String, dir_to_store_them: Dictionary) -> void:
	var dir = DirAccess.open(folder_path)
	if dir:
		for file_name in dir.get_files():
			if not file_name.ends_with(".tscn"):
				continue
			var scene: PackedScene = load(folder_path + file_name)
			if scene:
				var state = scene.get_state()
				var scene_name = state.get_node_name(0)
				dir_to_store_them[scene_name] = scene

func _process(delta) -> void:
	if Input.is_action_just_pressed("Left"):
		left_target()
	elif Input.is_action_just_pressed("Right"):
		right_target()
	elif Input.is_action_just_pressed("Select"):
		select_target()
	elif Input.is_action_just_pressed("Cancel"):
		cancel_action()

func perform_turn(character: CharacterBody2D):
	print(character.name, " is taking their turn")
	var moves = character.get_node_or_null("Moves")
	await handle_start_of_turn_status(character)
	
	current_character = character
	
	if moves:
		lower_cooldowns(moves)
	
	if character.get_parent() == Allies:
		var result = await handle_player_turn(character)
		if not result:
			return
	else:
		await handle_ai_turn(character)
		
	if not character:
		return
	
	end_turn(character)

func end_turn(character: CharacterBody2D):
	clean_old_moves()
	turn_taken.append(character)
	turn_order.remove_at(0)
	
	current_character = null
	hide_arrow(current_target)
	current_target = null
	
	await get_tree().create_timer(0.2).timeout
	
	next_turn()

func next_turn():
	if not is_fighting:
		return
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

func use_move(move, target = null):
	close_turn_ui()
	await move.use(target)
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
	
	close_turn_ui()
	
	await get_tree().create_timer(1).timeout

	if moves:
		var move_to_use = select_move(moves)
		if move_to_use:
			use_move(move_to_use)
			
	return true

func handle_player_turn(character):
	var moves = character.get_node_or_null("Moves")
	
	await clean_old_moves()

	set_up_turn_ui()
	create_move_buttons(moves)

	var old_round = current_round
	
	await get_tree().create_timer(10).timeout
	
	if not (current_character == character and old_round == current_round):
		return false
	
	return true

func create_move_buttons(moves):
	for move in moves.get_children():
		if move.name != "Attack":
			var newMoveIcon = SkillTemplate.duplicate()
			newMoveIcon.get_node("SkillName").text = move.name
			newMoveIcon.name = move.name
			newMoveIcon.visible = true
			newMoveIcon.disabled = move.current_cooldown > 0
			newMoveIcon.get_node("OnCooldown").visible = move.current_cooldown > 0
			newMoveIcon.get_node("OnCooldown").get_node("Cooldown").text = str(move.current_cooldown)
			
			newMoveIcon.mouse_entered.connect(func():
				Description.get_node("SkillName").text = move.name
				Description.get_node("Cooldown").text = str(move.cooldown)
				Description.get_node("SkillDescription").text = move.description
				
				Description.visible = true
			)
			
			newMoveIcon.mouse_exited.connect(func():
				if Description.get_node("SkillName").text == move.name:
					Description.visible = false
			)
			
			newMoveIcon.pressed.connect(func():
				move_button_pressed(move.name)
			)
			
			SkillsContainer.add_child(newMoveIcon)

func set_up_turn_ui():
	SkillsMenu.visible = false
	Buttons.visible = true
	
func close_turn_ui():
	SkillsMenu.visible = false
	Buttons.visible = false

func clean_old_moves():
	selected_move = null
	
	for move in SkillsContainer.get_children():
		if move.name != "Template":
			move.queue_free()
	
	return

func character_died(character):
	if current_character == character:
		end_turn(character)
	
	if character in turn_order:
		turn_order.remove_at(turn_order.find(character))
		
	if character in turn_taken:
		turn_taken.remove_at(turn_taken.find(character))
		
	if character.get_parent() == Allies and Allies.get_child_count() == 1:
		print("Player lost")
		end_fight(false)
		return
		
	if character.get_parent() == Enemies and Enemies.get_child_count() == 1:
		print("Player won")
		end_fight(true)
		return

func end_fight(player_won: bool):
	await get_tree().create_timer(0.6).timeout
	var results_info = {
		live_allies = {
			1: null,
			2: null,
			3: null,
			4: null
		},
		live_enemies = {
			1: null,
			2: null,
			3: null,
			4: null
		},
		info = {}
	}
	
	for ally in Allies.get_children():
		for i in range(AllyPositions.size()):
			if ally.global_position == AllyPositions[i].global_position:
				results_info.live_allies[i + 1] = ally.name
				break
	
	for enemy in Enemies.get_children():
		for i in range(EnemyPosition.size()):
			if enemy.global_position == EnemyPosition[i].global_position:
				results_info.live_enemies[i + 1] = enemy.name
				results_info.info[i + 1] = {}
				results_info.info[i + 1].health = enemy.health
				break
	
	EnemyChibis.fight_ended(results_info, player_won)
	
	for ally in Allies.get_children():
		ally.queue_free()
	
	for enemy in Enemies.get_children():
		enemy.queue_free()
		
	turn_order = []
	turn_taken = []
	current_round = 0
	is_fighting = false
	visible = false
	HUD.visible = false
	reenable_regular_hud()

func move_button_pressed(name):
	var moves = current_character.get_node_or_null("Moves")
	
	if not moves:
		return
	
	var move = moves.get_node_or_null(NodePath(name))
	if not move:
		return
		
	if "has_no_target" in move and move.has_no_target == true:
		await use_move(move, null)
		end_turn(current_character)
		return
		
	first_target()
	
	if name == "Attack":
		current_action = "TargetAttack"
	else:
		current_action = "TargetSkill"
	
	selected_move = move
	
	SkillsMenu.visible = false
	Buttons.visible = false
	
func show_select_arrow():
	var arrow = current_target.get_node_or_null("TargetSelectArrow")
	
	if not arrow:
		print("No arrow found")
		return
		
	arrow.visible = true
	
func hide_arrow(character):
	if not character:
		return
	var arrow = current_target.get_node_or_null("TargetSelectArrow")
	
	if not arrow:
		print("No arrow found")
		return
		
	arrow.visible = false
	
func first_target():
	current_target = Enemies.get_child(0)
	
	show_select_arrow()

func right_target():
	if not current_target:
		return
	var index = current_target.get_index()
	if index < Enemies.get_child_count() - 1:
		hide_arrow(current_target)
		current_target = Enemies.get_child(index + 1)
	
	show_select_arrow()
	
func left_target():
	if not current_target:
		return
	var index = current_target.get_index()
	if index > 0:
		hide_arrow(current_target)
		current_target = Enemies.get_child(index - 1)
		
	show_select_arrow()
	
func select_target():
	if not current_target:
		print("No current target")
		return
	
	hide_arrow(current_target)
	
	await use_move(selected_move, current_target)
	
	end_turn(current_character)
	
func cancel_action():
	if current_action == "TargetAttack":
		hide_arrow(current_target)
		Buttons.visible = true
	elif current_action == "TargetSkills":
		hide_arrow(current_target)
		SkillsMenu.visible = true
	elif current_action == "SelectingSkills":
		SkillsMenu.visible = false
		Buttons.visible = true
		
func handle_start_of_turn_status(character):
	var status = character.get_node_or_null("Status")
	if not status:
		print("No status found")
		return
	
	for effect in status.get_children():
		if effect.name == "Burn":
			character.take_damage(BURN_DAMAGE)
			
		StatusHandler.remove_status(character, effect.name, 1)
	
	return
