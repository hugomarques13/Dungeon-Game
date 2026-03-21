extends Sprite2D

@export var breath_scale_y: float = 1.01
@export var breath_duration: float = 2.8
@export var breath_duration_variance: float = 0.6

var _base_scale: Vector2
var _base_sprite_y: float
var _breath_tween: Tween

func _ready() -> void:
	_base_scale = scale
	_base_sprite_y = position.y
	_start_breathing()

func _start_breathing() -> void:
	var offset = randf_range(0.0, breath_duration)
	await get_tree().create_timer(offset).timeout

	var cycle_duration = breath_duration + randf_range(-breath_duration_variance, breath_duration_variance)
	var half = cycle_duration * 0.5

	var inhale_scale = Vector2(_base_scale.x, _base_scale.y * breath_scale_y)
	var rise = (texture.get_size().y * _base_scale.y) * (breath_scale_y - 1.0) * 0.5

	_breath_tween = create_tween()
	_breath_tween.set_loops()

	_breath_tween.tween_property(self, "scale", inhale_scale, half)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_breath_tween.parallel().tween_property(self, "position:y", _base_sprite_y - rise, half)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	_breath_tween.tween_property(self, "scale", _base_scale, half)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_breath_tween.parallel().tween_property(self, "position:y", _base_sprite_y, half)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
