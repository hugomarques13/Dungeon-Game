extends Control

const MAIN_GAME_SCENE = "res://Scenes/MainGame.tscn"

@onready var ContinueButton = $ContinueButton
@onready var NewGameButton = $NewGameButton

var ClickSound = preload("res://Sounds/MenuButtonClickSound.wav")

var base_music = preload("res://Sounds/Main Menu and Tutorial.mp3")

func _ready() -> void:
	MusicManager.play(base_music, -10)
	if not SaveManager.has_save():
		ContinueButton.disabled = true
		ContinueButton.modulate = Color(135,135,135)
	ContinueButton.pressed.connect(_on_continue_pressed)
	NewGameButton.pressed.connect(_on_new_game_pressed)

func _on_continue_pressed() -> void:
	play_sound()
	get_tree().change_scene_to_file(MAIN_GAME_SCENE)

func _on_new_game_pressed() -> void:
	play_sound()
	SaveManager.delete_save()
	get_tree().change_scene_to_file(MAIN_GAME_SCENE)

func play_sound():
	var audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = ClickSound
	audio.play()
	audio.finished.connect(audio.queue_free)
