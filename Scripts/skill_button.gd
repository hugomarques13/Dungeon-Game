extends TextureButton

@onready var Combat_Manager = $"../../../.."

func _on_button_down() -> void:
	Combat_Manager.move_button_pressed(name)
