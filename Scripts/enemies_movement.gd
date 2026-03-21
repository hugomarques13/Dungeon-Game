extends Node2D

@onready var FloorUI = $"../HUD/FloorUI"
@onready var NavigationAgent = $NavigationAgent2D
@onready var CombatManager = $"../Combat"
@onready var Shop = $"../HUD/Shop"
@onready var ChibiPositions = [
	$Pos1,
	$Pos2,
	$Pos3,
	$Pos4
]
@onready var FloorHandler = $"../HUD/FloorUI"
@onready var Player = $"../Player"
@onready var ShopOpener = $"../HUD/ShopOpener"
@onready var DungeonOpener = $"../HUD/DungeonOpener"
@onready var TopBar = $"../HUD/TopBar"
@onready var GameOver = $"../GameOver"
@onready var HUD = $"../HUD"
@onready var DialogueManager = $"../DialogueLayer/Dialogue"
var dungeon_state = "CLOSED"

var WalkStoneSound = preload("res://Sounds/WalkStone.ogg")
@onready var WalkAudio = $WalkAudio

const BLOOD_RANGE = 120.0
var _loop_active = true

var phases = {
	1: {
		1: {
			1: "Villager",
			2: null,
			3: null,
			4: null
		},
		2: {
			1: null,
			2: "Villager",
			3: "Torch Villager",
			4: null
		},
		3: {
			1: "Scarecrow",
			2: null,
			3: null,
			4: "Torch Villager"
		},
		4: {
			1: null,
			2: "Bull",
			3: null,
			4: null
		}
	},
	2: {
		1: {
			1: "Bull",
			2: null,
			3: "Fighter",
			4: null
		},
		2: {
			1: null,
			2: "Leader",
			3: "Spearman",
			4: null
		},
		3: {
			1: "Scarecrow",
			2: "Leader",
			3: "Fighter",
			4: "Scarecrow"
		},
		4: {
			1: "Barbarian",
			2: "Leader",
			3: "Spearman",
			4: "Fighter"
		}
	},
	3: {
		1: {
			1: "Priestess",
			2: "Leader Glowup",
			3: "Spearman Glowup",
			4: null
		},
		2: {
			1: null,
			2: "Barber",
			3: "Barbarian Glowup",
			4: "Fighter Glowup"
		},
		3: {
			1: null,
			2: "Barber",
			3: "Spearman Glowup",
			4: "Priestess"
		},
		4: {
			1: "Spearman Glowup",
			2: "Leader Glowup",
			3: "Scholar",
			4: "Priestess",
		}
	},
	4: {
		1: {
			1: "Barbarian Glowup",
			2: "Leader Glowup",
			3: "Scholar Glowup",
			4: "Priestess Glowup"
		},
		2: {
			1: "Scholar Glowup",
			2: "Barber",
			3: "Barbarian Glowup",
			4: "Spearman Glowup"
		},
		3: {
			1: "Barbarian Glowup",
			2: "Leader Glowup",
			3: "Spearman Glowup",
			4: "Fighter Glowup"
		},
		4: {
			1: "Barbarian Glowup",
			2: "Scholar Glowup",
			3: "Priestess Glowup",
			4: "Spearman Glowup",
		}
	},
}

var enemies = {
	squad = {
		1: null,
		2: null,
		3: null,
		4: null
	},
	info = {
		1: { "health": 0, "status": {} },
		2: { "health": 0, "status": {} },
		3: { "health": 0, "status": {} },
		4: { "health": 0, "status": {} },
	}
}

var base_info = {
	1: { "health": 0, "status": {} },
	2: { "health": 0, "status": {} },
	3: { "health": 0, "status": {} },
	4: { "health": 0, "status": {} },
}

var ZIndexes = {
	1: 1,
	2: 2,
	3: 1,
	4: 0,
}

var world_chibis = {
	1: null,
	2: null,
	3: null,
	4: null
}

var last_combat_units = {}

var BloodWall1 = preload("res://Prefabs/Blood/blood_wall_1.tscn")
var BloodWall2 = preload("res://Prefabs/Blood/blood_wall_2.tscn")
var BloodFloor1 = preload("res://Prefabs/Blood/blood_floor_1.tscn")
var BloodFloor2 = preload("res://Prefabs/Blood/blood_floor_2.tscn")

var chibis = {}
var enemy_prefabs = {}
var enemy_max_health = {}
var enemy_soul_reward = {}

var speed = 100.0
var current_floor = 0
var current_target = null
var points_list = []
var is_moving = false
var Floors = []

var _saved_traps = []
var _saved_fields = []

var current_phase = 1
var current_fight = 1

var floor_nav_maps = []

func _ready() -> void:
	await get_tree().process_frame
	_walk_sound_loop()
	Floors = FloorUI.floors

	for i in range(Floors.size()):
		var map = NavigationServer2D.map_create()
		NavigationServer2D.map_set_active(map, true)
		floor_nav_maps.append(map)

		var region = _find_navigation_region(Floors[i])
		if region:
			NavigationServer2D.region_set_map(region.get_region_rid(), map)
			print("Floor ", i, " assigned to map RID: ", map)

	NavigationAgent.connect("target_reached", Callable(self, "_on_target_reached"))
	await CombatManager.load_assets("res://Prefabs/Chibis/", chibis)
	await CombatManager.load_assets("res://Prefabs/Enemies/", enemy_prefabs)
	set_enemy_info()

	var file_data = SaveManager.load_save()
	if not file_data.is_empty():
		current_phase = int(file_data.get("current_phase", 1))
		current_fight = int(file_data.get("current_fight", 1))
		await get_tree().process_frame
		_restore_placed_objects(file_data)
		Shop.rebuild_placement_icons()
		Shop.update_all_amounts()
		FloorHandler._load_unlocked_floors()

	_save_full_state()

func _physics_process(delta: float) -> void:
	var next_pos = NavigationAgent.get_next_path_position()
	var direction = (next_pos - global_position)

	if direction.length() > 1.0:
		direction = direction.normalized()
		global_position += direction * speed * delta
		_update_chibi_directions(direction)
		if not is_moving:
			is_moving = true
			set_chibis_bobbing(true)
	else:
		if is_moving:
			is_moving = false
			set_chibis_bobbing(false)

func _update_chibi_directions(direction: Vector2) -> void:
	var iso_dir = direction.rotated(deg_to_rad(-45))
	var anim_name: String
	var flip_h: bool = false

	if abs(iso_dir.x) > abs(iso_dir.y):
		anim_name = "Front"
		flip_h = iso_dir.x > 0
	else:
		anim_name = "Front" if iso_dir.y > 0 else "Back"

	for pos in world_chibis.keys():
		var chibi = world_chibis[pos]
		if not chibi:
			continue
		chibi.flip_h = not flip_h
		if chibi.animation != anim_name:
			chibi.play(anim_name)

func move_to_next_target():
	NavigationAgent.set_velocity(Vector2.ZERO)
	NavigationAgent.target_position = current_target.global_position

func get_next_target():
	if dungeon_state == "CLOSED":
		print("Dungeon is closed")
		return

	var index
	if current_target == null:
		index = -1
	else:
		index = points_list.find(current_target)

	print("current_target is ", current_target, " index is ", index, "  ", len(points_list) - 1, "   ", points_list)

	if index < len(points_list) - 1:
		current_target = points_list[index + 1]
		print("Moving to ", current_target)
		await get_tree().process_frame
		move_to_next_target()

func update_points_list():
	points_list = []
	var points = Floors[current_floor].get_node_or_null("Points")
	if not points:
		print("No points list found for floor ", current_floor)
		return []

	var fight_markers = []
	var end_marker = null

	var marker_name = "End"

	if current_floor == FloorUI.unlocked_floors - 1:
		marker_name = "EndFinal"

	for marker in points.get_children():
		if not marker is Marker2D:
			continue
		if marker.name == marker_name:
			end_marker = marker
		elif marker.name.begins_with("Fight"):
			var num = int(marker.name.substr(5, marker.name.length() - 5))
			fight_markers.append({"marker": marker, "num": num})

	fight_markers.sort()

	for item in fight_markers:
		points_list.append(item["marker"])
	if end_marker:
		points_list.append(end_marker)

	print("Points list is ", points_list)

func start_fight():
	var num = int(current_target.name.substr(5, current_target.name.length() - 5))
	var flag = Floors[current_floor].get_node_or_null(NodePath("Flag" + str(num)))

	if not flag:
		print("Flag not found for ", current_target)
		return

	var allies = flag.Units
	var isEmpty = true
	var field = flag.field

	for ally in allies.values():
		if ally != null:
			isEmpty = false
			break

	if isEmpty:
		print("Fight spot is empty, moving on")
		get_next_target()
		return

	TransitionScreen.play()
	await get_tree().create_timer(0.15).timeout
	CombatManager.new_combat(allies, enemies.squad, enemies.info, field)

func change_floor():
	if current_floor == FloorUI.unlocked_floors - 1:
		_show_fail_screen()
		return

	var player_was_watching = FloorHandler.current_floor == current_floor
	current_floor += 1
	FloorHandler.increase_floor(player_was_watching)
	current_target = null
	place_at_start()
	update_points_list()
	get_next_target()

func _on_target_reached():
	print("reached ", current_target)
	if current_target.name == "End" or current_target.name == "EndFinal":
		change_floor()
		print("Floor finished")
		return
	else:
		start_fight()

func place_at_start():
	var start = Floors[current_floor].get_node_or_null("Start")
	if not start:
		print("No start marker found for ", current_floor)
		return
	global_position = start.global_position

	if current_floor < floor_nav_maps.size():
		NavigationAgent.set_navigation_map(floor_nav_maps[current_floor])
		print("Switched to floor ", current_floor, " map: ", floor_nav_maps[current_floor])

func _find_navigation_region(node: Node) -> NavigationRegion2D:
	if node is NavigationRegion2D:
		return node
	for child in node.get_children():
		var result = _find_navigation_region(child)
		if result:
			return result
	return null

func _get_current_phase_squad() -> Dictionary:
	if not phases.has(current_phase):
		print("Phase ", current_phase, " not found in phases")
		return { 1: null, 2: null, 3: null, 4: null }

	var phase = phases[current_phase]

	if not phase.has(current_fight):
		print("Fight ", current_fight, " not found in phase ", current_phase)
		return { 1: null, 2: null, 3: null, 4: null }

	return phase[current_fight].duplicate()

func _advance_phase_counter():
	if not phases.has(current_phase):
		return

	var phase = phases[current_phase]

	if phase.has(current_fight + 1):
		current_fight += 1
	elif phases.has(current_phase + 1):
		current_phase += 1
		current_fight = 1
		if current_phase == 3:
			FloorHandler.unlock_floor()
	else:
		HUD.visible = false
		SaveManager.mark_dialogue_seen("end")
		DialogueManager.start("end", func():
			CombatManager.new_combat(last_combat_units, {1: null, 2: "Lord Dungeonkin", 3: null, 4: null}, {}, "")
		)
		print("All phases completed — staying at last fight")

	# tutorial2 plays once after the very first fight (phase 1, fight 2)
	if current_fight == 2 and current_phase == 1:
		if not SaveManager.has_seen_dialogue("tutorial2"):
			SaveManager.mark_dialogue_seen("tutorial2")
			HUD.visible = false
			DialogueManager.start("tutorial2", func():
				HUD.visible = true
			)
	#else: # uncomment to test final fight easier
		#HUD.visible = false
		#SaveManager.mark_dialogue_seen("end")
		#DialogueManager.start("end", func():
			#CombatManager.new_combat(last_combat_units, {1: null, 2: "Lord Dungeonkin", 3: null, 4: null}, {}, "")
		#)
	
func spawn_enemies():
	var squad = _get_current_phase_squad()
	enemies.squad = squad
	enemies.info = base_info.duplicate(true)
	
	print("Spawned enemies with ", enemies)

	print("Spawning phase ", current_phase, " fight ", current_fight)

	current_floor = 0
	current_target = null
	place_at_start()

	for pos in enemies.squad.keys():
		var enemy = enemies.squad[pos]
		if enemy == null:
			continue

		if enemy in chibis:
			var chibi = chibis[enemy].instantiate()
			add_child(chibi)
			chibi.position = ChibiPositions[pos - 1].position
			chibi.z_index = ZIndexes[pos]
			world_chibis[pos] = chibi
			start_chibi_bob(chibi, pos)
		else:
			print("No chibi found for ", enemy)

		if enemy in enemy_max_health:
			enemies.info[pos].health = enemy_max_health[enemy]
		else:
			print("No prefab found for ", enemy)

	print(enemies)
	update_points_list()
	get_next_target()

func fight_ended(results_info, player_won: bool):
	print("Fight ended! with ", results_info)
	for pos in results_info.live_enemies:
		var enemy = results_info.live_enemies[pos]
		if enemy == null and enemies.squad[pos] != null:
			enemy_died(enemy, pos)

	enemies.info = results_info.info

	var num = int(current_target.name.substr(5, current_target.name.length() - 5))
	var flag = Floors[current_floor].get_node_or_null(NodePath("Flag" + str(num)))

	if not flag:
		print("Flag not found for ", current_target)
		return

	var allies = flag.Units

	for pos in results_info.live_allies:
		var ally = results_info.live_allies[pos]
		if ally == null and allies[pos] != null:
			flag.unit_died(allies[pos], pos)
		if ally != null and allies[pos] == null:
			var info = Shop.units[ally]
			flag.add_unit(ally, info)

	last_combat_units = flag.Units

	if player_won:
		close_dungeon()
	else:
		get_next_target()

func are_all_enemies_dead():
	for enemy in enemies.squad.values():
		if enemy != null:
			return false
	return true

func enemy_died(enemy, pos):
	enemies.squad[pos] = null
	if world_chibis[pos] != null:
		spawn_blood(world_chibis[pos].global_position)
		world_chibis[pos].queue_free()
		world_chibis[pos] = null

	if are_all_enemies_dead():
		close_dungeon()

func start_chibi_bob(chibi: Node2D, pos: int):
	var base_y = chibi.position.y
	var delay = (pos - 1) * 0.1
	await get_tree().create_timer(delay).timeout
	var tween = chibi.create_tween()
	tween.set_loops()
	tween.tween_property(chibi, "position:y", base_y + 10, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	tween.tween_property(chibi, "position:y", base_y, 0.25)\
		.set_trans(Tween.TRANS_SPRING)\
		.set_ease(Tween.EASE_OUT)

func set_chibis_bobbing(active: bool):
	for pos in world_chibis.keys():
		var chibi = world_chibis[pos]
		if not chibi:
			continue
		if active:
			start_chibi_bob(chibi, pos)
		else:
			var tween = chibi.create_tween()
			tween.set_loops()
			tween.tween_property(chibi, "position:y", ChibiPositions[pos - 1].position.y, 0.1)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_OUT)

func set_enemy_info():
	for enemyName in enemy_prefabs:
		var enemy = enemy_prefabs[enemyName].instantiate()
		enemy_max_health[enemyName] = enemy.max_health
		enemy_soul_reward[enemyName] = enemy.soul_reward
		enemy.queue_free()

func award_souls(enemy_name):
	if not enemy_soul_reward.has(enemy_name):
		print("No soul reward found for ", enemy_name)
		return
	var soul_amount = enemy_soul_reward[enemy_name]
	Player.add_souls(soul_amount)

func _collect_save_data() -> Dictionary:
	var player_data = Player.get_save_data()

	var flags_data = {}
	for flag in get_tree().get_nodes_in_group("Flag"):
		flags_data[str(flag.get_path())] = flag.get_save_data()

	var traps_data = []
	for trap in get_tree().get_nodes_in_group("PlacedTraps"):
		if not trap.has_meta("trap_name") or not trap.has_meta("tile"):
			continue
		var tile = trap.get_meta("tile")
		traps_data.append({
			"trap_name": trap.get_meta("trap_name"),
			"tile_path": str(tile.get_path()),
		})

	var fields_data = []
	for field in get_tree().get_nodes_in_group("PlacedFields"):
		if not field.has_meta("field_name") or not field.has_meta("tile"):
			continue
		var tile = field.get_meta("tile")
		fields_data.append({
			"field_name": field.get_meta("field_name"),
			"tile_path": str(tile.get_path()),
		})

	# Preserve the seen_dialogues array already on disk so we never overwrite it
	var existing = SaveManager.load_save()
	var seen_dialogues = existing.get("seen_dialogues", [])

	return {
		"player": player_data,
		"flags": flags_data,
		"traps": traps_data,
		"fields": fields_data,
		"current_phase": current_phase,
		"current_fight": current_fight,
		"seen_dialogues": seen_dialogues,
		"unlocked_floors": FloorHandler.unlocked_floors,
	}

func _save_full_state():
	# In-memory checkpoint for the rewind feature
	Player.save_state()
	for flag in get_tree().get_nodes_in_group("Flag"):
		flag.save_state()

	_saved_traps = []
	for trap in get_tree().get_nodes_in_group("PlacedTraps"):
		if not trap.has_meta("trap_name") or not trap.has_meta("tile"):
			continue
		var tile = trap.get_meta("tile")
		_saved_traps.append({
			"trap_name": trap.get_meta("trap_name"),
			"tile_path": tile.get_path(),
		})

	_saved_fields = []
	for field in get_tree().get_nodes_in_group("PlacedFields"):
		if not field.has_meta("field_name") or not field.has_meta("tile"):
			continue
		var tile = field.get_meta("tile")
		_saved_fields.append({
			"field_name": field.get_meta("field_name"),
			"tile_path": tile.get_path(),
		})

	# Persist to disk
	SaveManager.save(_collect_save_data())

func _restore_full_state():
	Player.restore_state()
	for flag in get_tree().get_nodes_in_group("Flag"):
		flag.restore_state()
 
	# Clear enemy status so traps/debuffs from the previous run don't carry over
	for pos in enemies.info.keys():
		enemies.info[pos] = { "health": 0, "status": {} }
	enemies.squad = { 1: null, 2: null, 3: null, 4: null }
 
	for trap in get_tree().get_nodes_in_group("PlacedTraps"):
		trap.queue_free()
 
	for saved in _saved_traps:
		var trap_name = saved["trap_name"]
		if not Shop.traps.has(trap_name):
			continue
		var info = Shop.traps[trap_name]
		var tile = get_node_or_null(saved["tile_path"])
		if not tile:
			continue
		var trap_instance = info.Scene.instantiate()
		trap_instance.visible = true
		trap_instance.set_meta("tile", tile)
		trap_instance.set_meta("trap_name", trap_name)
		trap_instance.add_to_group("PlacedTraps")
		tile.get_parent().add_child(trap_instance)
		trap_instance.global_position = tile.global_position
		var trap_placed = trap_instance
		trap_placed.get_node("ClickBox").input_event.connect(func(viewport, event, shape_idx):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if dungeon_state == "CLOSED":
					Shop.trap_clicked(trap_placed)
		)
 
	for field in get_tree().get_nodes_in_group("PlacedFields"):
		field.queue_free()
 
	for saved in _saved_fields:
		var field_name = saved["field_name"]
		if not Shop.fields.has(field_name):
			continue
		var info = Shop.fields[field_name]
		var tile = get_node_or_null(saved["tile_path"])
		if not tile:
			continue
		var field_instance = info.Scene.instantiate()
		field_instance.visible = true
		field_instance.set_meta("tile", tile)
		field_instance.set_meta("field_name", field_name)
		field_instance.add_to_group("PlacedFields")
		tile.get_parent().add_child(field_instance)
		field_instance.global_position = tile.global_position
		var flag_node = tile.get_node(tile.get_meta("Flag"))
		flag_node.field = field_name
		var field_placed = field_instance
		field_placed.get_node("ClickBox").input_event.connect(func(viewport, event, shape_idx):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if dungeon_state == "CLOSED":
					Shop.field_clicked(field_placed)
		)
 
	for pos in world_chibis.keys():
		if world_chibis[pos] != null:
			world_chibis[pos].queue_free()
			world_chibis[pos] = null
 
	Shop.update_all_amounts()

func _restore_placed_objects(file_data: Dictionary) -> void:
	var flags_data: Dictionary = file_data.get("flags", {})
	for flag in get_tree().get_nodes_in_group("Flag"):
		var key = str(flag.get_path())
		if flags_data.has(key):
			flag.load_save_data(flags_data[key])

	var traps_data: Array = file_data.get("traps", [])
	for saved in traps_data:
		var trap_name = saved["trap_name"]
		if not Shop.traps.has(trap_name):
			continue
		var info = Shop.traps[trap_name]
		var tile = get_node_or_null(saved["tile_path"])
		if not tile:
			continue
		var trap_instance = info.Scene.instantiate()
		trap_instance.visible = true
		trap_instance.set_meta("tile", tile)
		trap_instance.set_meta("trap_name", trap_name)
		trap_instance.add_to_group("PlacedTraps")
		tile.get_parent().add_child(trap_instance)
		trap_instance.global_position = tile.global_position
		var trap_placed = trap_instance
		trap_placed.get_node("ClickBox").input_event.connect(func(viewport, event, shape_idx):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if dungeon_state == "CLOSED":
					Shop.trap_clicked(trap_placed)
		)

	var fields_data: Array = file_data.get("fields", [])
	for saved in fields_data:
		var field_name = saved["field_name"]
		if not Shop.fields.has(field_name):
			continue
		var info = Shop.fields[field_name]
		var tile = get_node_or_null(saved["tile_path"])
		if not tile:
			continue
		var field_instance = info.Scene.instantiate()
		field_instance.visible = true
		field_instance.set_meta("tile", tile)
		field_instance.set_meta("field_name", field_name)
		field_instance.add_to_group("PlacedFields")
		tile.get_parent().add_child(field_instance)
		field_instance.global_position = tile.global_position
		var flag_node = tile.get_node(tile.get_meta("Flag"))
		flag_node.field = field_name
		var field_placed = field_instance
		field_placed.get_node("ClickBox").input_event.connect(func(viewport, event, shape_idx):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if dungeon_state == "CLOSED":
					Shop.field_clicked(field_placed)
		)

func stop_movement():
	place_at_start()
	NavigationAgent.target_position = Vector2(-1000, -1000)

func close_dungeon():
	print("Dungeon was ", dungeon_state, " closing it down ", dungeon_state == "OPEN")
	if dungeon_state == "OPEN":
		stop_movement()
		dungeon_state = "CLOSED"
		is_moving = false
		set_chibis_bobbing(false)
		_advance_phase_counter()
		_save_full_state()
		ShopOpener.visible = true
		DungeonOpener.visible = true
		TopBar.visible = true

func open_dungeon():
	if dungeon_state == "CLOSED":
		FloorHandler.reset_to_floor_zero()
		dungeon_state = "OPEN"
		ShopOpener.visible = false
		DungeonOpener.visible = false
		Shop.visible = false
		TopBar.visible = false
		spawn_enemies()

func _on_dungeon_opener_pressed() -> void:
	open_dungeon()

func _show_fail_screen():
	dungeon_state = "CLOSED"

	for pos in world_chibis.keys():
		if world_chibis[pos] != null:
			world_chibis[pos].queue_free()
			world_chibis[pos] = null

	GameOver.visible = true

	GameOver.get_node("Checkpoint").pressed.connect(func():
		FloorHandler.reset_to_floor_zero()
		await _play_clock_rewind_animation()
		GameOver.visible = false
		if not Player.has_saved_state():
			print("No saved state available")
			get_tree().reload_current_scene()
			return
		_restore_full_state()
		ShopOpener.visible = true
		DungeonOpener.visible = true
		TopBar.visible = true

		HUD.visible = false
		if not SaveManager.has_seen_dialogue("rewind"):
			SaveManager.mark_dialogue_seen("rewind")
			DialogueManager.start("rewind", func():
				HUD.visible = true
			)
		else:
			HUD.visible = true
	)

	GameOver.get_node("Restart").pressed.connect(func():
		get_tree().reload_current_scene()
	)

func _play_clock_rewind_animation() -> void:
	var minute_hand = GameOver.get_node("ClockHandMinutes")
	var hour_hand = GameOver.get_node("ClockHandHours")
 
	# Reset hands to 12 o'clock before the animation begins
	minute_hand.rotation_degrees = 0.0
	hour_hand.rotation_degrees = 0.0
 
	const DURATION = 6.0
	const MAX_RATIO = 12.0
	const MIN_RATIO = 3.0
 
	var elapsed = 0.0
	var minute_degrees = 0.0
	var hour_degrees = 0.0
	var transition_played = false
 
	while elapsed < DURATION:
		var delta = get_process_delta_time()
		elapsed += delta
 
		var t = elapsed / DURATION
		var speed_factor = pow(t, 0.3)
 
		const MAX_DEG_PER_SEC = 1800.0
		var ratio = lerp(MAX_RATIO, MIN_RATIO, pow(t, 0.3))
 
		var minute_delta = MAX_DEG_PER_SEC * speed_factor * delta
		var hour_delta = (MAX_DEG_PER_SEC / ratio) * speed_factor * delta
 
		minute_degrees -= minute_delta
		hour_degrees -= hour_delta
 
		minute_hand.rotation_degrees = minute_degrees
		hour_hand.rotation_degrees = hour_degrees
 
		if not transition_played and elapsed >= DURATION - 0.25:
			transition_played = true
			TransitionScreen.fade_to_white()
 
		await get_tree().process_frame

func spawn_blood(origin: Vector2) -> void:
	var floor_tiles_in_range = []
	var empty_floor_tiles = []
	var wall_tiles_in_range = []
	var empty_wall_tiles = []

	for tile in get_tree().get_nodes_in_group("FloorTile"):
		if tile.global_position.distance_to(origin) <= BLOOD_RANGE:
			floor_tiles_in_range.append(tile)
			if not tile.get_node_or_null("BloodFloor"):
				empty_floor_tiles.append(tile)

	for tile in get_tree().get_nodes_in_group("WallTile"):
		var adjusted_pos = tile.global_position + Vector2(0, 11)
		if adjusted_pos.distance_to(origin) <= BLOOD_RANGE:
			wall_tiles_in_range.append(tile)
			if not tile.get_node_or_null("BloodWall"):
				empty_wall_tiles.append(tile)

	var can_place_floor = not floor_tiles_in_range.is_empty()
	var can_place_wall = not wall_tiles_in_range.is_empty()

	if not can_place_floor and not can_place_wall:
		return

	var place_on_wall: bool
	if can_place_floor and can_place_wall:
		place_on_wall = randi() % 2 == 0
	else:
		place_on_wall = can_place_wall

	if place_on_wall:
		var pool = empty_wall_tiles if not empty_wall_tiles.is_empty() else wall_tiles_in_range
		var target = pool[randi() % pool.size()]
		var blood = _wall_blood_for(target).instantiate()
		target.add_child(blood)
		blood.global_position = target.global_position + Vector2(0, 11)
	else:
		var pool = empty_floor_tiles if not empty_floor_tiles.is_empty() else floor_tiles_in_range
		var target = pool[randi() % pool.size()]
		var blood = _random_floor_blood().instantiate()
		target.add_child(blood)
		blood.global_position = target.global_position

func _wall_blood_for(tile: Node) -> PackedScene:
	if tile.has_meta("IsWall2"):
		return BloodWall2
	return BloodWall1

func _random_floor_blood() -> PackedScene:
	if randi() % 2 == 0:
		return BloodFloor1
	return BloodFloor2
	
func _exit_tree() -> void:
	_loop_active = false

func _walk_sound_loop():
	while _loop_active:
		if not is_instance_valid(self) or is_queued_for_deletion():
			return
		var tree = get_tree()
		if not tree:
			return
		if is_moving:
			WalkAudio.play()
			await WalkAudio.finished
			if not _loop_active or not is_instance_valid(self) or is_queued_for_deletion():
				return
			tree = get_tree()
			if not tree:
				return
			await tree.create_timer(0.15).timeout
		else:
			if not _loop_active or not is_instance_valid(self) or is_queued_for_deletion():
				return
			await get_tree().process_frame
