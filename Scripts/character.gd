extends CharacterBody2D

@export var soul_reward: int = 0

@export var max_health: float = 100


@export var base_attack_damage: float = 50
@export var base_attack_amount: int = 1

@export var base_attack_effect: String = "Slash"


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
var Player

var _base_scale: Vector2
var _breath_tween: Tween
var _base_sprite_y: float
var _base_position_y: float = 0.0
var is_dead = false

func _ready():
	if get_parent().name != "Character":
		Player = $"../../../Player"
	health = max_health
	sprite.material = sprite.material.duplicate()
	update_hp_bar()
	_base_scale = sprite.scale
	_base_sprite_y = sprite.position.y
	_start_breathing()

func _start_breathing() -> void:
	if name == "Lord Dungeonkin":
		_start_hovering()
		return

	var offset = randf_range(0.0, breath_duration)
	await get_tree().create_timer(offset).timeout

	var cycle_duration = breath_duration + randf_range(-breath_duration_variance, breath_duration_variance)
	var half = cycle_duration * 0.5

	var inhale_scale = Vector2(_base_scale.x, _base_scale.y * breath_scale_y)
	var rise = (_get_sprite_texture_size().y * _base_scale.y) * (breath_scale_y - 1.0) * 0.5

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

func _start_hovering() -> void:
	var hover_height: float = 6.0
	var hover_duration: float = 1.6

	_breath_tween = create_tween()
	_breath_tween.set_loops()

	_breath_tween.tween_property(sprite, "position:y", _base_sprite_y - hover_height, hover_duration)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_breath_tween.tween_property(sprite, "position:y", _base_sprite_y, hover_duration)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _get_sprite_texture_size() -> Vector2:
	if sprite is AnimatedSprite2D:
		var frames = sprite.sprite_frames
		if frames and frames.get_frame_count(sprite.animation) > 0:
			return frames.get_frame_texture(sprite.animation, 0).get_size()
		return Vector2.ZERO
	elif sprite is Sprite2D:
		if sprite.texture:
			return sprite.texture.get_size()
		return Vector2.ZERO
	return Vector2.ZERO

func take_damage(damage: float, is_crit: bool = false, soul_multiplier: float = 1.0):
	# negative damage is healing
	if health - damage >= max_health:
		health = max_health
	else:
		health -= damage
	create_damage_indicator(damage, is_crit)
	update_hp_bar()
	blink_red()
	if health <= 0:
		die(soul_multiplier)

func die(soul_multiplier: float = 1.0):
	print(name, " has died!")
	if _breath_tween:
		_breath_tween.kill()
	sprite.scale = _base_scale

	# Immortal check
	if character.get_meta("Immortal", false):
		tween_shake()
		var drop_amount = _get_sprite_texture_size().y * 2
		if _base_position_y == 0.0:
			_base_position_y = position.y
		else:
			position.y = _base_position_y
		var origin_y = position.y

		var tween_down_half = create_tween()
		tween_down_half.tween_property(self, "position:y", origin_y + drop_amount * 0.25, 0.6) \
			.set_ease(Tween.EASE_IN)
		await tween_down_half.finished

		var tween_up = create_tween()
		tween_up.tween_property(self, "position:y", origin_y, 0.6) \
			.set_ease(Tween.EASE_OUT)
		await tween_up.finished

		is_dead = false
		health = 1.0
		update_hp_bar()
		_start_breathing()
		return
		
	is_dead = true

	# Normal death
	Combat_Manager.character_died(character)
	GUI.visible = false
	sprite.material = null

	if get_parent().name == "Enemies":
		Player.add_souls(floori(soul_reward * soul_multiplier))

	tween_shake()
	tween_fade()
	await tween_down()
	queue_free()

func update_hp_bar():
	var hp_percentage = clamp(health / max_health, 0, 1)
	hp_bar.scale.x = hp_percentage

func create_damage_indicator(damage: float, is_crit: bool = false):
	var indicator = damage_indicator.instantiate()
	if damage < 0:
		damage = abs(damage)
		indicator.add_theme_color_override("font_color", Color(0,255,0))
	
	add_child(indicator)
	indicator.global_position = global_position + Vector2(randi_range(-40, 0), -80)
	indicator.setup(int(damage), is_crit)
	
func create_text_indicator(text: String, color):
	var indicator = damage_indicator.instantiate()

	indicator.add_theme_color_override("font_color", color)
	
	add_child(indicator)
	indicator.global_position = global_position + Vector2(randi_range(-40, 0), -80)
	indicator.z_index = 2
	indicator.setup(text, false)

func blink_red():
	var mat = sprite.material
	mat.set_shader_parameter("flash_color", Color(255,0,0))
	mat.set_shader_parameter("flash_amount", 1.0)
	await get_tree().create_timer(0.1).timeout
	mat.set_shader_parameter("flash_amount", 0.0)

func tween_down():
	var tween = create_tween()
	var drop_amount = _get_sprite_texture_size().y * 2
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
