extends CharacterBody2D

@export var max_health: float = 100

var health: float = max_health

@onready var hp_bar = $GUI/Bar
@onready var Combat_Manager = $"../.."
@onready var character = $"."

func _ready():
	update_hp_bar()

func take_damage(damage: float):
	health -= damage
	
	update_hp_bar()
	
	if health <= 0:
		die()
		
func die():
	print(name, " has died!")
	Combat_Manager.character_died(character)
	
	await get_tree().create_timer(0.1).timeout
	
	queue_free()

func update_hp_bar():
	var hp_percentage = clamp(health / max_health,0,1)
	
	hp_bar.scale.x = hp_percentage
