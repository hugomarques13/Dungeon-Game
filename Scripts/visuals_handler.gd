extends Node

var hit_effects: Dictionary = {
	"Blunt": {
		"scene": preload("res://Prefabs/Effects/blunt_hit.tscn"),
		"sound": preload("res://Sounds/BluntHit.mp3"),
	},
	"Slash": {
		"scene": preload("res://Prefabs/Effects/slash_effect.tscn"),
		"sound": preload("res://Sounds/Slash_Hit.mp3"),
	},
	"Fire": {
		"scene": preload("res://Prefabs/Effects/CombatFire.tscn"),
		"sound": preload("res://Sounds/BurnHit.mp3"),
	},
	"Magic": {
		"scene": preload("res://Prefabs/Effects/magic_blast.tscn"),
		"sound": preload("res://Sounds/MagicHit.mp3"),
	},
	"Heal": {
		"scene": preload("res://Prefabs/Effects/heal_effect.tscn"),
		"sound": preload("res://Sounds/Heal_Hit.mp3"),
	},
	"Buff": {
		"scene": preload("res://Prefabs/Effects/buff_effect.tscn"),
		"sound": preload("res://Sounds/Buff_Hit.wav"),
	},
	"Debuff": {
		"scene": preload("res://Prefabs/Effects/debuff_effect.tscn"),
		"sound": preload("res://Sounds/Debuff_Hit.mp3"),
	},
	"Dark": {
		"scene": preload("res://Prefabs/Effects/dark_effect.tscn"),
		"sound": preload("res://Sounds/Dark_Hit.mp3"),
	},
	"Bite": {
		"scene": preload("res://Prefabs/Effects/bite_effect.tscn"),
		"sound": preload("res://Sounds/Bite_Hit.wav"),
	},
	"DarkBite": {
		"scene": preload("res://Prefabs/Effects/dark_bite_effect.tscn"),
		"sound": preload("res://Sounds/Bite_Hit.wav"),
	},
}

var WhereToParent

func make_visual(character: CharacterBody2D, effect: String) -> void:
	if not hit_effects.has(effect):
		push_warning("make_visual: unknown effect '%s'" % effect)
		return

	if not character:
		return

	var entry = hit_effects[effect]

	var instance = entry["scene"].instantiate()
	WhereToParent.add_child(instance)
	instance.position = character.position

	if entry["sound"] != null:
		var audio = AudioStreamPlayer.new()
		WhereToParent.add_child(audio)
		audio.stream = entry["sound"]
		audio.play()
		audio.finished.connect(audio.queue_free)

	instance.play("default")
	await instance.animation_finished
	instance.queue_free()

func make_visual_multi(targets: Array, effect: String) -> void:
	for target in targets.slice(1):
		VisualsHandler.make_visual(target, effect)
	await VisualsHandler.make_visual(targets[0], effect)
