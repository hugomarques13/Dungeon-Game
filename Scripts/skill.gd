extends TextureButton

@onready var SkillsMenu = $"../../SkillsMenu"
@onready var Buttons = $".."
@onready var CombatManager = $"../../.."

func _on_button_down() -> void:
	SkillsMenu.visible = true
	Buttons.visible = false
	CombatManager.current_action = "SelectingSkills"
