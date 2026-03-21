extends Node2D

var cooldown := 5
var current_cooldown := 0
var has_no_target = true

var description = "Tell them the unbearable truth, forcing enemies to attack you."

const status_amount = 3

var yahoo = preload("res://Sounds/yahoomaxxing.mp3")

@onready var character = $"../.."

func use(_false_target):
	# extra safety
	if current_cooldown > 0:
		print("test move on cooldown, sorry")
		return
		
	var audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = yahoo
	audio.play()
	audio.finished.connect(audio.queue_free)
		
	await VisualsHandler.make_visual(character, "Buff")
	
	character.create_text_indicator("TAUNT", Color(0.902, 0.0, 0.159, 1.0))
	
	StatusHandler.apply_status(character, "Taunt", status_amount)
	
	return
