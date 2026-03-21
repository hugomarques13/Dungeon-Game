extends Control

@onready var floors = [
	$"../../Floor1",
	$"../../Floor2",
	$"../../Floor3"
]

@onready var camera = $"../../Camera2D"
@onready var ChibiPlace = $"../../ChibiPlace"
@onready var DownButton = $DownButton
@onready var UpButton = $UpButton

var current_floor = 0
var unlocked_floors = 2
var amount_to_move= 0
var amount_to_move_down = 0

func _ready():
	var distance = get_node("Floor2").position.y - get_node("Floor1").position.y
	amount_to_move = distance
	_load_unlocked_floors()

func update_camera():
	var current_floor = floors[current_floor]
	var center = current_floor.get_node_or_null("Center")
	
	if not center:
		print("Center not found")
		return
	
	var tween = create_tween()
	tween.tween_property(camera, "global_position", center.global_position, 0.5)
	
	ChibiPlace.position = current_floor.position

func update_text(old_value):
	var old_text_label = get_node_or_null(NodePath("Floor"+str(old_value+1)))
	
	if old_text_label:
		old_text_label.scale = Vector2(1,1)
	
	var text_label = get_node_or_null(NodePath("Floor"+str(current_floor+1)))
	
	if text_label:
		text_label.scale = Vector2(1.5,1.5)

func increase_floor(follow: bool = true):
	if current_floor + 1 >= unlocked_floors:
		return
	
	if not follow:
		return
	
	current_floor += 1
	update_text(current_floor - 1)
	update_camera()
	
func decrease_floor():
	if current_floor - 1 < 0:
		return
	
	current_floor -= 1
	
	update_text(current_floor+1)
	update_camera()
	
func unlock_floor():
	if unlocked_floors + 1 > len(floors):
		print("Unlocked all floors")
		return
	
	unlocked_floors += 1
	
	var floor_text = get_node_or_null("Floor"+str(unlocked_floors))
	if not floor_text:
		print("No floor icon found for ", unlocked_floors)
		return
	
	floor_text.visible = true
	
	var dungeon_kin_icon = floors[unlocked_floors-2].get_node_or_null("Ritual")
	if dungeon_kin_icon:
		dungeon_kin_icon.visible = false
		
	var stairs = floors[unlocked_floors-2].get_node_or_null("Stairs")
	if stairs:
		stairs.visible = true
	
	DownButton.position.y += amount_to_move
	position.y += amount_to_move/2

func _on_up_button_button_down() -> void:
	decrease_floor()

func _on_down_button_button_down() -> void:
	increase_floor()
	
func reset_to_floor_zero():
	var old_floor = current_floor
	current_floor = 0
	update_text(old_floor)
	update_camera()
	
func _load_unlocked_floors():
	var data = SaveManager.load_save()
	print(data)
	var saved_floors = data.get("unlocked_floors", 2)
	print("Saved floor is ", saved_floors)
	while unlocked_floors < saved_floors:
		unlock_floor()
