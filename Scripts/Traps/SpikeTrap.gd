extends Area2D

@onready var EnemyHandler = $"../../../Chibis"
@onready var AnimatedSprite = $".."

const DAMAGE = 20
const status_amount = 2
const status_name = "Bleed"

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
			if enemy and enemy_info.health > 0:
				enemy_info.health -= DAMAGE
				
				if not enemy_info.status.has(status_name):
					enemy_info.status[status_name] = 0
					
				enemy_info.status[status_name] += status_amount
				
				if enemy_info.health <= 0:
					EnemyHandler.award_souls(enemy)
					EnemyHandler.enemy_died(enemy, pos)
		

func visual_effect():
	AnimatedSprite.play("default")
	
	await AnimatedSprite.animation_finished
	
	AnimatedSprite.play("default", -1.5)
	
	await AnimatedSprite.animation_finished
	
	on_cooldown = false
