extends TextureButton

@onready var SkillsMenu = $"../../SkillsMenu"
@onready var Buttons = $".."
@onready var CombatManager = $"../../.."
@onready var BackButton = $"../../BackButton"

func _on_button_down() -> void:
	SkillsMenu.visible = true
	Buttons.visible = false
	BackButton.visible = true
	CombatManager.current_action = "SelectingSkills"
