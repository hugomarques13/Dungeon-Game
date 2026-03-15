extends Control

@onready var UnitsContainer = $UnitsContainer
@onready var TrapsContainer = $TrapsContainer


func _on_units_pressed() -> void:
	UnitsContainer.visible = true
	TrapsContainer.visible = false
	

func _on_traps_pressed() -> void:
	UnitsContainer.visible = false
	TrapsContainer.visible = true
