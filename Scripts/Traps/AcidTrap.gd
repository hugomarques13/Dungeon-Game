extends Area2D

@onready var EnemyHandler = $"../../../Chibis"

const status_amount = 2
const status_name = "Weakened"

var sound = preload("res://Sounds/Acid_Trap.wav")

var on_cooldown = false

func _on_area_entered(area: Area2D) -> void:
	if on_cooldown:
		return
	
	if area.get_parent().has_meta("IsEnemy"):
		
		on_cooldown = true
		visual_effect()
		
		var enemies = EnemyHandler.enemies
		
		for pos in enemies.info:
			var enemy_info = enemies.info[pos]
			var enemy = enemies.squad[pos]
			if enemy:
				if not enemy_info.status.has(status_name):
					enemy_info.status[status_name] = 0
					
				enemy_info.status[status_name] += status_amount
		

func visual_effect():
	var audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = sound
	audio.play()
	audio.finished.connect(audio.queue_free)
	await get_tree().create_timer(2).timeout
	
	on_cooldown = false
