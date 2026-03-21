extends Area2D

@onready var EnemyHandler = $"../../../Chibis"
@onready var AnimatedSprite = $"../FireVisual"

const status_amount = 3
const status_name = "Burn"

var on_cooldown = false

func _on_area_entered(area: Area2D) -> void:
	if on_cooldown:
		return
		
	print("Fir etrap entered")
		
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
	AnimatedSprite.visible = true
	AnimatedSprite.play("default")
	
	await AnimatedSprite.animation_finished
	
	AnimatedSprite.visible = false
	
	on_cooldown = false
