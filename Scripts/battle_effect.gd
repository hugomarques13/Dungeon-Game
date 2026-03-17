extends Node2D

@onready var character = $".."
var sprite

func _ready() -> void:
	sprite = character.find_children("", "Sprite2D", false)[0]
	
	await get_tree().create_timer(2).timeout
	
	blinking()
	
	

func blinking():
	var mat = sprite.material

	for i in range(4):
		mat.set_shader_parameter("flash_amount", 1.0)
		await get_tree().create_timer(0.05).timeout
		mat.set_shader_parameter("flash_amount", 0.0)
		await get_tree().create_timer(0.05).timeout
