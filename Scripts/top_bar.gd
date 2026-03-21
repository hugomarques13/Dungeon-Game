extends Control

@onready var UnitsContainer = $UnitsContainer
@onready var TrapsContainer = $TrapsContainer
@onready var FieldsContainer = $FieldsContainer


func _on_units_pressed() -> void:
	UnitsContainer.visible = true
	TrapsContainer.visible = false
	FieldsContainer.visible = false


func _on_traps_pressed() -> void:
	UnitsContainer.visible = false
	TrapsContainer.visible = true
	FieldsContainer.visible = false


func _on_fields_pressed() -> void:
	UnitsContainer.visible = false
	TrapsContainer.visible = false
	FieldsContainer.visible = true
