extends Area2D

@onready var EnemyHandler = $"../../../Chibis"
@onready var AnimatedSprite = $"../AnimatedSprite2D"

const status_amount = 1
const status_name = "Stun"

var on_cooldown = false

func _on_area_entered(area: Area2D) -> void:
	if on_cooldown:
		return
		
	print("Stun Trap !!!! entered!")
		
	if area.get_parent().has_meta("IsEnemy"):
		
		on_cooldown = true
		visual_effect()
		
		var enemies = EnemyHandler.enemies
		var potential_targets = []
		
		for pos in enemies.info:
			var enemy = enemies.squad[pos]
			if enemy:
				potential_targets.append(pos)
	
		potential_targets.shuffle()
		
		var chosen_target_info = enemies.info[potential_targets[0]]
		if not chosen_target_info.status.has(status_name):
			chosen_target_info.status[status_name] = 0
			
		chosen_target_info.status[status_name] += status_amount
		

func visual_effect():
	AnimatedSprite.play("default")
	
	await AnimatedSprite.animation_finished
	
	on_cooldown = false
