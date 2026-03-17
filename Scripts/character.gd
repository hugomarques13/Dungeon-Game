extends CharacterBody2D

@export var max_health: float = 100
@export var base_attack_damage: float = 50
@export var base_attack_amount: int = 1
@export var breath_scale_y: float = 1.01
@export var breath_duration: float = 2.8
@export var breath_duration_variance: float = 0.6

var damage_indicator = preload("res://Prefabs/damage_text.tscn")
var health: float

@onready var sprite = $Sprite2D
@onready var GUI = $GUI
@onready var hp_bar = $GUI/Bar
@onready var Combat_Manager = $"../.."
@onready var character = $"."

var _base_scale: Vector2
var _breath_tween: Tween
var _base_sprite_y: float
var is_dead = false

func _ready():
	health = max_health
	sprite.material = sprite.material.duplicate()
	update_hp_bar()
	_base_scale = sprite.scale
	_base_sprite_y = sprite.position.y
	_start_breathing()

func _start_breathing() -> void:
	var offset = randf_range(0.0, breath_duration)
	await get_tree().create_timer(offset).timeout

	var cycle_duration = breath_duration + randf_range(-breath_duration_variance, breath_duration_variance)
	var half = cycle_duration * 0.5

	var inhale_scale = Vector2(_base_scale.x, _base_scale.y * breath_scale_y)
	var rise = (sprite.texture.get_size().y * _base_scale.y) * (breath_scale_y - 1.0) * 0.5

	_breath_tween = create_tween()
	_breath_tween.set_loops()

	_breath_tween.tween_property(sprite, "scale", inhale_scale, half)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_breath_tween.parallel().tween_property(sprite, "position:y", _base_sprite_y - rise, half)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	_breath_tween.tween_property(sprite, "scale", _base_scale, half)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_breath_tween.parallel().tween_property(sprite, "position:y", _base_sprite_y, half)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func take_damage(damage: float):
	health -= damage
	create_damage_indicator(damage)
	update_hp_bar()
	blink_red()
	if health <= 0:
		die()

func die():
	print(name, " has died!")
	is_dead = true
	if _breath_tween:
		_breath_tween.kill()
	sprite.scale = _base_scale
	Combat_Manager.character_died(character)
	GUI.visible = false
	sprite.material = null
	tween_shake()
	tween_fade()
	await tween_down()
	queue_free()

func update_hp_bar():
	var hp_percentage = clamp(health / max_health, 0, 1)
	hp_bar.scale.x = hp_percentage
	print(health, " ", max_health, " ", hp_percentage)

func create_damage_indicator(damage: float):
	var indicator = damage_indicator.instantiate()
	add_child(indicator)
	indicator.global_position = global_position + Vector2(randi_range(-40, 0), -80)
	indicator.setup(damage)

func blink_red():
	var mat = sprite.material
	mat.set_shader_parameter("flash_amount", 1.0)
	await get_tree().create_timer(0.1).timeout
	mat.set_shader_parameter("flash_amount", 0.0)

func tween_down():
	var tween = create_tween()
	var drop_amount = sprite.texture.get_size().y * 2
	tween.tween_property(self, "position:y", position.y + drop_amount, 1.2).set_ease(Tween.EASE_IN)
	await tween.finished

func tween_fade():
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0, 0.4).set_ease(Tween.EASE_IN)

func tween_shake():
	var tween = create_tween()
	var origin = sprite.position
	tween.set_loops(5)
	tween.tween_property(sprite, "position:x", origin.x + 3, 0.05)
	tween.tween_property(sprite, "position:x", origin.x - 3, 0.05)
