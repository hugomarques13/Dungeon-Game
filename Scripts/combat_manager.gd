extends Node2D

const BURN_DAMAGE = 10
const BLEED_DAMAGE = 10

@onready var Allies = $Allies
@onready var Enemies = $Enemies
@onready var HUD = $HUD
@onready var Buttons = $HUD/Buttons
@onready var SkillsMenu = $HUD/SkillsMenu
@onready var BackButton = $HUD/BackButton
@onready var SkillsContainer = $HUD/SkillsMenu/GridContainer
@onready var SkillTemplate = $HUD/SkillsMenu/GridContainer/Template
@onready var Description = $HUD/SkillsMenu/Description
@onready var AllyPositions = [
	$Slots/Allies/Slot1,
	$Slots/Allies/Slot2,
	$Slots/Allies/Slot3,
	$Slots/Allies/Slot4
]
@onready var EnemyPositions = [
	$Slots/Enemies/Slot1,
	$Slots/Enemies/Slot2,
	$Slots/Enemies/Slot3,
	$Slots/Enemies/Slot4
]
@onready var RegularHUD = $"../HUD"
@onready var EnemyChibis = $"../Chibis"
@onready var FloorUI = $"../HUD/FloorUI"
@onready var Background = $Background
@onready var VisualsNode = $Visuals
@onready var SkillVisualIndicator = $HUD/SkillName
@onready var LordPosition = $Slots/Enemies/LordSpot
@onready var DialogueManager = $"../DialogueLayer/Dialogue"

var boss_music = preload("res://Sounds/03- Soul Party.mp3")
var combat_music = preload("res://Sounds/Dungeon Battle Music.mp3")
var base_music = preload("res://Sounds/Cathedral.mp3")

const background_images = {
	"Default": {
		"Bottom": preload("res://Sprites/Background/DefaultField1.png"),
		"Top": preload("res://Sprites/Background/DefaultField2.png")
	},
	"Haste Field": {
		"Bottom": preload("res://Sprites/Background/Haste1.png"),
		"Top": preload("res://Sprites/Background/Haste2.png")
	},
	"Impair Field": {
		"Bottom": preload("res://Sprites/Background/Impair1.png"),
		"Top": preload("res://Sprites/Background/Impair2.png")
	},
}

const ending_scene = preload("res://Scenes/Ending.tscn")

var Floors = []

var turn_order = []
var turn_taken = []
var current_round = 0
var current_character = null

var selected_move = null
var current_target = null
var current_action = null

var is_fighting = false
var current_field = ""

var ally_scenes = {}
var enemy_scenes = {}

var HUD_visibility = {}

func _ready() -> void:
	await get_tree().process_frame
	Floors = FloorUI.floors
	TargetGetter.Allies = Allies
	TargetGetter.Enemies = Enemies
	TargetGetter.AllyPositions = AllyPositions
	TargetGetter.EnemyPositions = EnemyPositions
	VisualsHandler.WhereToParent = VisualsNode
	
	load_assets("res://Prefabs/Allies/", ally_scenes)
	load_assets("res://Prefabs/Enemies/", enemy_scenes)
	
func summon_character(scene_name: String, slot: int, summoner: CharacterBody2D):
	var scenes = ally_scenes if summoner.get_parent() == Allies else enemy_scenes
	var positions = AllyPositions if summoner.get_parent() == Allies else EnemyPositions
	var parent = Allies if summoner.get_parent() == Allies else Enemies
	
	if not scene_name in scenes:
		print("Scene not found: ", scene_name)
		return
	
	var character = scenes[scene_name].instantiate()
	parent.add_child(character)
	character.global_position = positions[slot - 1].global_position
	character.set_meta("slot", slot)
	
	turn_order.append(character)

func new_combat(allies_dict, enemies_dict, enemies_info, field):
	var played_music = false
	print("New combat started with ", allies_dict, "\n", enemies_dict, "\n", enemies_info)
	for pos in allies_dict.keys():
		var ally = allies_dict[pos]
		
		if not ally:
			continue
		
		var character = ally_scenes[ally].instantiate()
		
		print("Added ally ", character)
		Allies.add_child(character)
		
		character.global_position = AllyPositions[pos-1].global_position
		character.set_meta("slot", pos)
	
	for pos in enemies_dict.keys():
		var enemy = enemies_dict[pos]
		
		if not enemy:
			continue
		
		var character = enemy_scenes[enemy].instantiate()
		
		print("Added enemy ", character)
		Enemies.add_child(character)
		
		if enemy == "Lord Dungeonkin":
			character.global_position = LordPosition.global_position
			MusicManager.play(boss_music, -10)
			played_music = true
		else:
			character.global_position = EnemyPositions[pos-1].global_position
		character.set_meta("slot", pos)
		
		if pos in enemies_info and enemies_info[pos] != null:
			character.health = enemies_info[pos].health
			character.update_hp_bar()
		
			for statusName in enemies_info[pos].status:
				var amount = enemies_info[pos].status[statusName]
				StatusHandler.apply_status(character, statusName, amount)
				
	MusicManager.play(combat_music, -10)
				
	if field == "" or not background_images.has(field):
		field = "Default"
	
	current_field = field
	
	Background.get_node("BackgroundTop").texture = background_images[field].Top
	Background.get_node("BackgroundBottom").texture = background_images[field].Bottom
	
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
		
	await get_tree().process_frame
	
	start_round()

func disable_regular_hud():
	HUD_visibility = {}
	for hud_item in RegularHUD.get_children():
		if hud_item.name == "FloorUI":
			HUD_visibility[hud_item] = hud_item.visible
			hud_item.visible = false

func reenable_regular_hud():
	for hud_item in HUD_visibility.keys():
			hud_item.visible = HUD_visibility[hud_item]

func load_assets(folder_path: String, dir_to_store_them: Dictionary) -> void:
	var dir = DirAccess.open(folder_path)
	if not dir:
		push_error("Could not open folder: " + folder_path)
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn") or file_name.ends_with(".tscn.remap"):
			var load_path = folder_path + file_name.replace(".remap", "")
			var scene: PackedScene = ResourceLoader.load(load_path)
			if scene:
				var state = scene.get_state()
				var scene_name = state.get_node_name(0)
				dir_to_store_them[scene_name] = scene
		file_name = dir.get_next()
	dir.list_dir_end()

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
	start_blink(character)
	print(character.name, " is taking their turn")
	var moves = character.get_node_or_null("Moves")
	current_character = character
	var skip_turn = await handle_start_of_turn_status(character)
	
	# Character might die from status effect and it is no longer their turn
	if current_character != character:
		return
	
	if moves:
		lower_cooldowns(moves)
		
	if skip_turn:
		end_turn(character)
		return
	
	if character.get_parent() == Allies:
		handle_player_turn(character)
	else:
		await handle_ai_turn(character)
		
		if not character:
			return
		
		end_turn(character)

func end_turn(character: CharacterBody2D):
	stop_blink()
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
	display_move_name(move.name)
	close_turn_ui()
	await move.use(target)
	
	var cooldown = move.cooldown
	
	if current_field == "Haste Field" and current_character.get_parent() == Allies:
		cooldown = max(0, cooldown - 1)
	elif current_field == "Impair Field" and current_character.get_parent() == Enemies:
		cooldown = cooldown + 1
		
	if move.name == "Attack":
		cooldown = 0
	
	move.current_cooldown = cooldown
	
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
		var used_ultimate = false
		if character.has_meta("Lord") and not move_to_use:
			move_to_use = moves.get_node(NodePath("../UltimateMove/Reality Hemorrhage"))
			used_ultimate = true
		
		if move_to_use:
			await use_move(move_to_use)
			
		if used_ultimate:
			end_fight(false)
			
	return true

func handle_player_turn(character):
	var moves = character.get_node_or_null("Moves")
	
	await clean_old_moves()

	set_up_turn_ui()
	create_move_buttons(moves)
	
	

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
	BackButton.visible = false
	
func close_turn_ui():
	SkillsMenu.visible = false
	Buttons.visible = false
	BackButton.visible = false

func clean_old_moves():
	selected_move = null
	
	for move in SkillsContainer.get_children():
		if move.name != "Template":
			move.queue_free()
	
	return

func character_died(character):
	
	if character in turn_order:
		turn_order.erase(character)
		
	if character in turn_taken:
		turn_taken.erase(character)
	
	var was_current = (current_character == character)
	var parent = character.get_parent()
	var alive_allies = Allies.get_children().filter(func(a): return not a.is_dead)
	var alive_enemies = Enemies.get_children().filter(func(e): return not e.is_dead)
	
	if parent == Allies and alive_allies.size() <= 0:
		print("Player lost")
		end_fight(false)
		return
		
	if parent == Enemies and alive_enemies.size() <= 0:
		print("Player won")
		end_fight(true)
		return
	
	if was_current:
		current_character = null
		hide_arrow(current_target)
		current_target = null
		await get_tree().create_timer(0.2).timeout
		next_turn()

func end_fight(player_won: bool):
	await get_tree().create_timer(0.6).timeout
	MusicManager.play(base_music, -10)
	
	for enemy in Enemies.get_children():
		if enemy.has_meta("Lord"):
			EnemyChibis._exit_tree()
	
			await get_tree().process_frame
			get_tree().change_scene_to_packed(ending_scene)
			break
	
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
		if ally.has_meta("slot") and not ally.is_dead:
			results_info.live_allies[ally.get_meta("slot")] = ally.name
	
	for enemy in Enemies.get_children():
		if enemy.has_meta("slot") and not enemy.is_dead:
			var slot = enemy.get_meta("slot")
			results_info.live_enemies[slot] = enemy.name
			results_info.info[slot] = {}
			results_info.info[slot].health = enemy.health
			results_info.info[slot].status = {}
			for status in enemy.get_node("Status").get_children():
				results_info.info[slot].status[status.name] = status.get_meta("Amount")
	
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
		
	if "is_aoe" in move and move.is_aoe == true:
		selected_move = move
		current_action = "TargetSkill"
		show_arrows(get_living_enemies())
		BackButton.visible = true
		SkillsMenu.visible = false
		Buttons.visible = false
		return
	
	if "hits_all_except_self" in move and move.hits_all_except_self == true:
		selected_move = move
		current_action = "TargetSkill"
		var targets = Allies.get_children().filter(func(a): return a != current_character and not a.is_dead)
		targets.append_array(get_living_enemies())
		show_arrows(targets)
		BackButton.visible = true
		SkillsMenu.visible = false
		Buttons.visible = false
		return
		
	first_target()
	
	if name == "Attack":
		current_action = "TargetAttack"
	else:
		current_action = "TargetSkill"
	
	selected_move = move
	
	BackButton.visible = true
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
	
func get_living_enemies() -> Array:
	return Enemies.get_children().filter(func(e): return not e.is_dead)
	
func get_valid_targets() -> Array:
	var taunted = get_taunt_targets()
	return taunted if not taunted.is_empty() else get_living_enemies()

func first_target():
	if not SaveManager.has_seen_dialogue("tutorial4"):
		SaveManager.mark_dialogue_seen("tutorial4")
		DialogueManager.start("tutorial4")
	var targets = get_valid_targets()
	if targets.is_empty():
		return
	current_target = targets[0]
	show_select_arrow()

func right_target():
	if not current_target:
		return
	var targets = get_valid_targets()
	var index = targets.find(current_target)
	if index < targets.size() - 1:
		hide_arrow(current_target)
		current_target = targets[index + 1]
	show_select_arrow()

func left_target():
	if not current_target:
		return
	var targets = get_valid_targets()
	var index = targets.find(current_target)
	if index > 0:
		hide_arrow(current_target)
		current_target = targets[index - 1]
	show_select_arrow()
	
func select_target():
	if not selected_move:
		print("No selected move")
		return
	
	var move_to_use = selected_move
	selected_move = null
	
	if current_target:
		hide_arrow(current_target)
	else:
		# AOE / hits_all_except_self — hide all arrows
		hide_arrows(Allies.get_children() + Enemies.get_children())
	
	await use_move(move_to_use, current_target)
	end_turn(current_character)
	
func show_arrows(targets: Array):
	for target in targets:
		var arrow = target.get_node_or_null("TargetSelectArrow")
		if arrow:
			arrow.visible = true

func hide_arrows(targets: Array):
	for target in targets:
		var arrow = target.get_node_or_null("TargetSelectArrow")
		if arrow:
			arrow.visible = false
	
func cancel_action():
	if current_action == "TargetAttack":
		if current_target:
			hide_arrow(current_target)
		else:
			hide_arrows(Allies.get_children() + Enemies.get_children())
		current_target = null
		selected_move = null
		current_action = null
		BackButton.visible = false
		Buttons.visible = true
	elif current_action == "TargetSkill":
		if current_target:
			hide_arrow(current_target)
		else:
			hide_arrows(Allies.get_children() + Enemies.get_children())
		current_target = null
		selected_move = null
		current_action = "SelectingSkills"
		SkillsMenu.visible = true
	elif current_action == "SelectingSkills":
		SkillsMenu.visible = false
		BackButton.visible = false
		Buttons.visible = true
		
func handle_start_of_turn_status(character):
	var status = character.get_node_or_null("Status")
	if not status:
		print("No status found")
		return
		
	var skip_turn = false
	
	for effect in status.get_children():
		if effect.name == "Burn":
			if character.has_meta("BurnImmunity") and character.get_meta("BurnImmunity") == true:
				print("character is immune to burn damage")
			else:
				VisualsHandler.make_visual(character, "Fire")
				character.take_damage(BURN_DAMAGE)
		
		if effect.name == "Bleed":
			character.take_damage(BLEED_DAMAGE)
			
		if effect.name == "Stun":
			skip_turn = true
			
		if effect.name == "Flaming Munchies":
			var targets = TargetGetter.get_aoe_enemy_targets(character)
			
			await VisualsHandler.make_visual_multi(targets, "Fire")
			
			for target in targets:
				DamageHandler.do_damage(character, target, 80, {"Burn": 5})
			
			DamageHandler.do_damage(character, character, 999, {})
			
		if effect.name == "Prayer of Healing":
			var targets = TargetGetter.get_aoe_ally_targets(character)
			
			await VisualsHandler.make_visual_multi(targets, "Heal")
			
			for target in targets:
				DamageHandler.do_damage(character, target, -100, {})
			
		StatusHandler.remove_status(character, effect.name, 1)
	
	return skip_turn


func _on_back_button_pressed() -> void:
	cancel_action()

func start_blink(character: CharacterBody2D) -> void:
	stop_blink()
	var mat = character.get_node("Sprite2D").material
	mat.set_shader_parameter("outline_color", Color(1, 1, 1))
	mat.set_shader_parameter("outline_width", 2.0)

func stop_blink() -> void:
	if current_character:
		var mat = current_character.get_node("Sprite2D").material
		mat.set_shader_parameter("outline_width", 0.0)
		
func get_taunt_targets() -> Array:
	return get_living_enemies().filter(func(e): return e.get_node_or_null("Status") and e.get_node("Status").get_node_or_null("Taunt") != null)

func display_move_name(moveName: String):
	var random_rotation = randf_range(-0.5, 0.5)
	SkillVisualIndicator.rotation = deg_to_rad(random_rotation)
	SkillVisualIndicator.modulate.a = 0.0
	
	var label = SkillVisualIndicator.get_node("Label")
	var bg = SkillVisualIndicator
	
	label.text = moveName
	label.modulate.a = 0.0
	bg.modulate.a = 0.0
	SkillVisualIndicator.visible = true
	
	var tween_in = create_tween().set_parallel(true)
	tween_in.tween_property(bg, "modulate:a", 0.85, 0.2)
	tween_in.tween_property(label, "modulate:a", 1.0, 0.1)
	await tween_in.finished
	
	await get_tree().create_timer(0.4).timeout
	
	# Tween out: both to 0%
	var tween_out = create_tween().set_parallel(true)
	tween_out.tween_property(bg, "modulate:a", 0.0, 0.2)
	tween_out.tween_property(label, "modulate:a", 0.0, 0.2)
	await tween_out.finished
	
	SkillVisualIndicator.visible = false
