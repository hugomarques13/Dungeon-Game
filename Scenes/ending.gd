extends Control
@onready var label = $Label
@onready var Credits = $Credits
var main_menu = preload("res://Scenes/MainMenu.tscn")
var music = preload("res://Sounds/Main Menu and Tutorial.mp3")

var sentences = [
	"With the crisis resolved, the Kingdom of Velobia pulled out of the Valleys of Discord.",
	"After downsizing his ruling, The Grand Majesty of Evil, Lord Dungeonkin continues to operate unperturbed for another great number of years.",
	"But fate and karma alike dictate a sinner shall never know true peace. This is the immutable truth.",
	"A future crisis remains to be seen..."
]

var current_sentence = 0
var current_char = 0
var displayed_text = ""
var is_typing = false
var is_done = false

@onready var timer = Timer.new()

func _ready():
	MusicManager.play(music, -10)
	Credits.visible = false
	add_child(timer)
	timer.wait_time = 0.04
	timer.timeout.connect(_on_timer_timeout)
	start_typing()

func start_typing():
	is_typing = true
	current_char = 0
	timer.start()

func _on_timer_timeout():
	var sentence = sentences[current_sentence]
	if current_char < sentence.length():
		current_char += 1
		label.text = displayed_text + sentence.substr(0, current_char)
	else:
		timer.stop()
		is_typing = false

func finish_sentence():
	timer.stop()
	var sentence = sentences[current_sentence]
	label.text = displayed_text + sentence
	current_char = sentence.length()
	is_typing = false

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_done:
			get_tree().change_scene_to_packed(main_menu)
			return

		if is_typing:
			finish_sentence()
		else:
			displayed_text = label.text + "\n\n"
			current_sentence += 1

			if current_sentence >= sentences.size():
				Credits.visible = true
				is_done = true
			else:
				start_typing()
