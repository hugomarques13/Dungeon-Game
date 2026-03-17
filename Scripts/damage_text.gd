extends Label

var velocity := Vector2.ZERO
var gravity := 200.0
var lifetime := 1.0
var timer := 0.0

func setup(damage: float):
	text = str(int(damage))
	velocity = Vector2(randf_range(-60, 60), randf_range(-180, -120))

func _process(delta):
	timer += delta
	velocity.y += gravity * delta
	position += velocity * delta
	
	var fade_start = lifetime - 0.3
	if timer >= fade_start:
		modulate.a = 1.0 - (timer - fade_start) / 0.3
	
	if timer >= lifetime:
		queue_free()
