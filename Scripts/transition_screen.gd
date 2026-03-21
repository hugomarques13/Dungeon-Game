extends Node

signal transition_finished

var _overlay: ColorRect

func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	
	_overlay = ColorRect.new()
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_overlay)

func play() -> void:
	var tween := create_tween()
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	
	tween.tween_property(_overlay, "color:a", 1.0, 0.15)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUART)
	
	tween.tween_interval(0.3)
	
	tween.tween_property(_overlay, "color:a", 0.0, 2)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	emit_signal("transition_finished")

func fade_to_white() -> void:
	var tween := create_tween()
	_overlay.color = Color(1.0, 1.0, 1.0, 0.0)
	tween.tween_property(_overlay, "color:a", 1.0, 0.25)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUART)
	tween.tween_interval(0.5)
	tween.tween_property(_overlay, "color:a", 0.0, 2)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
	await tween.finished
	emit_signal("transition_finished")
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
