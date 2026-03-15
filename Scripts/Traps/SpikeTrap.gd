extends Area2D

@onready var EnemyHandler = $"../../../Chibis"
@onready var AnimatedSprite = $".."

const DAMAGE = 20

var on_cooldown = false

func _on_area_entered(area: Area2D) -> void:
	if on_cooldown:
		return
	
	on_cooldown = true
	visual_effect()
	
	var enemies = EnemyHandler.enemies
	
	for pos in enemies.info:
		var enemy_info = enemies.info[pos]
		var enemy = enemies.squad[pos]
		if enemy_info.health > 0:
			enemy_info.health -= DAMAGE
			
			if enemy_info.health <= 0:
				EnemyHandler.enemy_died(enemy, pos)
		

func visual_effect():
	AnimatedSprite.play("default")
	
	await AnimatedSprite.animation_finished
	
	AnimatedSprite.play("default", -1.5)
	
	await AnimatedSprite.animation_finished
	
	on_cooldown = false
