extends Sprite2D

func _ready() -> void:
	var tween = create_tween()
	tween.set_loops()
	
	tween.tween_property(self, "position:y", position.y - 10, 0.8) # move up
	tween.tween_property(self, "position:y", position.y, 0.8) # move down
