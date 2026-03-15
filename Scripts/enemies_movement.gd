extends Node2D

@onready var Floors = [
	$"../Floor1",
	$"../Floor2"
]
@onready var NavigationAgent = $NavigationAgent2D
@onready var CombatManager = $"../Combat"
@onready var Shop = $"../HUD/Shop"
@onready var ChibiPositions = [
	$Pos1,
	$Pos2,
	$Pos3,
	$Pos4
]

var enemies = {
	squad = {
		1: "Villager",
		2: null,
		3: "Villager",
		4: null
	},
	info = {}
}

var world_chibis = {
	1: null,
	2: null,
	3: null,
	4: null
}

var chibis = {}

var speed = 100.0  # pixels per second

var current_floor = 0
var current_target = null
var points_list = []
var is_moving = false

func _ready() -> void:
	NavigationAgent.connect("target_reached", Callable(self, "_on_target_reached"))
	
	CombatManager.load_assets("res://Prefabs/Chibis/", chibis)
	#$"../Floor1/NavigationRegion2D".bake_navigation_polygon(true) # this is used if we use barricades to block pathfinding

func _physics_process(delta: float) -> void:
	var next_pos = NavigationAgent.get_next_path_position()

	var direction = (next_pos - global_position)
	if direction.length() > 1.0:
		direction = direction.normalized()
		global_position += direction * speed * delta
		if not is_moving:
			is_moving = true
			set_chibis_bobbing(true)
	else:
		if is_moving:
			is_moving = false
			set_chibis_bobbing(false)
		
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
	fight_markers.sort_custom(_sort_markers_by_num)
	
	for item in fight_markers:
		points_list.append(item["marker"])
	if end_marker:
		points_list.append(end_marker)

func _sort_markers_by_num(a, b):
	return a["num"] - b["num"]
	
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
	if current_floor + 1 == len(Floors):
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
	place_at_start()
	
	for pos in enemies.squad.keys():
		var enemy = enemies.squad[pos]
		
		if enemy == null:
			continue
		
		if enemy in chibis:
			var chibi = chibis[enemy].instantiate()
			add_child(chibi)
			
			chibi.position = ChibiPositions[pos-1].position
			world_chibis[pos] = chibi
			
			start_chibi_bob(chibi, pos)
		else:
			print("No chibi found for unit")
		
	update_points_list()
	get_next_target()

func fight_ended(results_info, player_won: bool):
	print("Fight ended! with ", results_info)
	for pos in results_info.live_enemies:
		var enemy = results_info.live_enemies[pos]
		if enemy == null and enemies.squad[pos] != null:
			world_chibis[pos].queue_free()
			world_chibis[pos] = null
			
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
			
	get_next_target()
	
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
			print("started tweening")
			start_chibi_bob(chibi, pos)
		else:
			# Kill tween and snap back to base Y
			print("stopped tweening")
			var tween = chibi.create_tween()
			tween.set_loops()
			tween.tween_property(chibi, "position:y", ChibiPositions[pos-1].position.y, 0.1)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_OUT)

func _on_dungeon_opener_pressed() -> void:
	spawn_enemies()
