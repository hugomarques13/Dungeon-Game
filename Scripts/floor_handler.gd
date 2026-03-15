extends Control

@onready var floors= [
	$"../../Floor1",
	$"../../Floor2"
]

@onready var camera = $"../../Camera2D"
@onready var ChibiPlace = $"../../ChibiPlace"

var current_floor = 0

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

func increase_floor():
	if current_floor + 1 >= len(floors):
		return
	
	current_floor += 1
	
	update_text(current_floor-1)
	update_camera()
	
func decrease_floor():
	if current_floor - 1 < 0:
		return
	
	current_floor -= 1
	
	update_text(current_floor+1)
	update_camera()

func _on_up_button_button_down() -> void:
	decrease_floor()

func _on_down_button_button_down() -> void:
	increase_floor()
