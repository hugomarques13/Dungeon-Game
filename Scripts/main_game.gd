extends Node2D
@onready var DialogueManager = $DialogueLayer/Dialogue
@onready var HUD = $HUD
@onready var ForegroundCover = $Background/ForegroundCover

var second_music = preload("res://Sounds/Cathedral.mp3")

func _ready() -> void:
	ForegroundCover.visible = true
	HUD.visible = false

	if SaveManager.has_seen_dialogue("intro"):
		# Returning player — skip straight to gameplay
		var tween := create_tween()
		tween.tween_property(ForegroundCover, "modulate:a", 0.0, 1.0)\
			.set_ease(Tween.EASE_IN)\
			.set_trans(Tween.TRANS_QUART)
		await tween.finished
		HUD.visible = true
		MusicManager.play(second_music, -10)
		return

	DialogueManager.start("intro", func():
		SaveManager.mark_dialogue_seen("intro")
		var tween := create_tween()
		tween.tween_property(ForegroundCover, "modulate:a", 0.0, 1.0)\
			.set_ease(Tween.EASE_IN)\
			.set_trans(Tween.TRANS_QUART)
		await tween.finished
		if SaveManager.has_seen_dialogue("tutorial1"):
			HUD.visible = true
			return
		DialogueManager.start("tutorial1", func():
			SaveManager.mark_dialogue_seen("tutorial1")
			HUD.visible = true
			MusicManager.play(second_music, -10)
		)
	)
