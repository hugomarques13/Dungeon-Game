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

var enemies = {
	squad = {
		1: null,
		2: null,
		3: null,
		4: null
	},
	info = {
		1: {
			"health": 0,
			"status": {}
		},
		2: {
			"health": 0,
			"status": {}
		},
		3: {
			"health": 0,
			"status": {}
		},
		4: {
			"health": 0,
			"status": {}
		},
	}
}

const first_fight = {
	1: "Leader",
	2: "Barbarian",
	3: "Spearman",
	4: "Fighter"
}

var base_info = {
	1: {
		"health": 0,
		"status": {}
	},
	2: {
		"health": 0,
		"status": {}
	},
	3: {
		"health": 0,
		"status": {}
	},
	4: {
		"health": 0,
		"status": {}
	},
}

var ZIndexes = {
	1: 2,
	2: 1,
	3: 1,
	4: 0,
}

var world_chibis = {
	1: null,
	2: null,
	3: null,
	4: null
}

var chibis = {}
var enemy_prefabs = {}
var enemy_max_health = {}

var speed = 100.0  # pixels per second

var current_floor = 0
var current_target = null
var points_list = []
var is_moving = false
var Floors = []

func _ready() -> void:
	await get_tree().process_frame
	Floors = FloorUI.floors
	print("Floors are ", Floors)
	NavigationAgent.connect("target_reached", Callable(self, "_on_target_reached"))
	
	CombatManager.load_assets("res://Prefabs/Chibis/", chibis)
	await CombatManager.load_assets("res://Prefabs/Enemies/", enemy_prefabs)
	
	set_enemies_max_hp()
	
	#$"../Floor1/NavigationRegion2D".bake_navigation_polygon(true) # this is used if we use barricades to block pathfinding

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
	var index
	if current_target == null:
		index = -1
	else:
		index = current_target.get_index() - 1
	
	if index < len(points_list) - 1:
		current_target = points_list[index + 1]
		
		move_to_next_target()

func update_points_list():
	points_list = []
	var points = Floors[current_floor].get_node_or_null("Points")
	if not points:
		print("No points list found for floor ", current_floor)
		return []

	var fight_markers = []
	var end_marker = null
	
	for marker in points.get_children():
		if not marker is Marker2D:
			continue
		
		if marker.name == "End":
			end_marker = marker
		elif marker.name.begins_with("Fight"):
			var num = int(marker.name.substr(5, marker.name.length() - 5))
			fight_markers.append({"marker": marker, "num": num})

	# Sort fight markers by number
	fight_markers.sort()
	
	for item in fight_markers:
		points_list.append(item["marker"])
	if end_marker:
		points_list.append(end_marker)
		
	print("Points list is ", points_list)

	
func start_fight():
	var num = int(current_target.name.substr(5, current_target.name.length() - 5))
	var flag = Floors[current_floor].get_node_or_null(NodePath("Flag"+str(num)))
	
	if not flag:
		print("Flag not found for ", current_target)
		return
	
	var allies = flag.Units
	
	var isEmpty = true
	
	for ally in allies.values():
		if ally != null:
			isEmpty = false
			break
	
	if isEmpty:
		get_next_target()
		return
	
	CombatManager.new_combat(allies, enemies.squad, enemies.info)

func change_floor():
	if current_floor == FloorUI.unlocked_floors:
		print("Dungeon finished!")
		return
	current_floor += 1
	
	place_at_start()
	update_points_list()
	get_next_target()

func _on_target_reached():
	print("reached ", current_target)
	
	await get_tree().create_timer(0.6).timeout
	
	if current_target.name == "End":
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

func spawn_enemies():
	enemies.squad = first_fight.duplicate()
	enemies.info = base_info.duplicate()
	
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
			
			chibi.position = ChibiPositions[pos-1].position
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
	var flag = Floors[current_floor].get_node_or_null(NodePath("Flag"+str(num)))
	
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
			
	if player_won:
		FloorHandler.unlock_floor()
	else:
		get_next_target()
	
func enemy_died(enemy, pos):
	# place blood effect
	enemies.squad[pos] = null
	world_chibis[pos].queue_free()
	world_chibis[pos] = null

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
			tween.tween_property(chibi, "position:y", ChibiPositions[pos-1].position.y, 0.1)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_OUT)
				
func set_enemies_max_hp():
	for enemyName in enemy_prefabs:
		var enemy = enemy_prefabs[enemyName].instantiate()
		
		enemy_max_health[enemyName] = enemy.max_health
		
		enemy.queue_free()
		

func _on_dungeon_opener_pressed() -> void:
	spawn_enemies()
