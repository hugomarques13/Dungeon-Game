extends Control

@onready var TextLabel = $DialogueText/Label
@onready var Tutoh = $TutorialMan
@onready var DungeonKin = $DungeonKin
@onready var NameLabel = $DialogueName/Label
@onready var ContinueIcon = $ContinueIcon
@onready var SkipButton = $SkipButton

var dialogue_groups = {
	"intro": [
		{ "speaker": "Tutoh", "anim": "Smirk", "text": "Hail, Grand Majesty Of Evil, Lord Dungeonkin." },
		{ "speaker": "Tutoh", "anim": "Default", "text": "There's commotion outside, my Grand Majesty." },
		{ "speaker": "DungeonKin", "anim": "Default", "text": "Hm..." },
		{ "speaker": "DungeonKin", "anim": "Thinking", "text": "...Yes, I've seen that..." },
		{ "speaker": "Tutoh", "anim": "Default", "text": "It seems the Kingdom of Velobia founded a settlement just outside." },
		{ "speaker": "Tutoh", "anim": "Default", "text": "With intentions of reclaiming this long lost Valley of yours..." },
		{ "speaker": "DungeonKin", "anim": "Stressed", "text": "Oh, excellent... is that not just excellent... I suppose they miss me." },
		{ "speaker": "Tutoh", "anim": "Shocked", "text": "Really? I thought they hated you." },
		{ "speaker": "DungeonKin", "anim": "Anger", "text": "..." },
		{ "speaker": "Tutoh", "anim": "Default", "text": "I estimate they'll be sending their troops, sir. This must be part of some campaign by their government." },
		{ "speaker": "Tutoh", "anim": "Smirk", "text": "Our scouts spoke of some hotshot party lead by the son of a Velobian Scholar...." },
		{ "speaker": "DungeonKin", "anim": "Stressed", "text": "...This valley has been mine for longer than their government has existed." },
		{ "speaker": "DungeonKin", "anim": "Stressed", "text": "Their founding fathers were in diapers when I was already a ruler." },
		{ "speaker": "Tutoh", "anim": "Smirk", "text": "Grand Majesty is still young in spirit." },
		{ "speaker": "DungeonKin", "anim": "Stressed", "text": "..." },
		{ "speaker": "DungeonKin", "anim": "Default", "text": "...We will amass forces and defend our ways." },
		{ "speaker": "DungeonKin", "anim": "Default", "text": "I will prepare a ritual to collapse their town under." },
		{ "speaker": "DungeonKin", "anim": "Thinking", "text": "In the meantime, we shall set up our defenses." },
		{ "speaker": "DungeonKin", "anim": "Default", "text": "I will not take this disrespect lying down." },
		{ "speaker": "DungeonKin", "anim": "Default", "text": "We've toiled at our own pace long enough." },
	],
	"tutorial1": [ # After fade in from last dialogue
		{ "speaker": "Tutoh", "anim": "Default", "text": "Since we haven't done this in some millennia, let's take it from the top, Grand Majesty." },
		{ "speaker": "Tutoh", "anim": "Default", "text": "I've handed you a spare 40 Souls from our stash. Drag 2 Zombies from the top left to the Totem." },
		{ "speaker": "DungeonKin", "anim": "Default", "text": "...Which one is the Totem again?" },
		{ "speaker": "Tutoh", "anim": "Shocked", "text": "The blue tile with the red pole in the middle." },
		{ "speaker": "Tutoh", "anim": "Smirk", "text": "Drag them, and we can 'Resume Time' and deal with these... invaders." },
	],
	"tutorial2": [ # After first fight
		{ "speaker": "Tutoh", "anim": "Default", "text": "We've harvested some Souls from that villager. Let's open up the Shop to spend them." },
	],
	"tutorial3": [ # After player opens the shop for the first time
		{ "speaker": "Tutoh", "anim": "Default", "text": "For our defenses we have three categories: Units, Traps and Fields. They must be unlocked before being able to be purchased." },
		{ "speaker": "Tutoh", "anim": "Default", "text": "Units go directly into battle, as demonstrated. Keep in mind a Totem can only hold 4 Units at once." },
		{ "speaker": "Tutoh", "anim": "Smirk", "text": "Traps can be placed on empty tiles around The Dungeon to impede and hinder the invaders before they reach our troops." },
		{ "speaker": "Tutoh", "anim": "Smirk", "text": "Fields are special. They are placed on the Totem tiles specifically. Fields will grant helpful effects during battle.." },
	],
	"tutorial4": [ # First combat
		{ "speaker": "Tutoh", "anim": "Default", "text": "You can use A, D or the arrow keys to pick your targets, and Space Bar to attack. What was I saying...? I'm sure it makes sense to you, Grand Majesty." },
	],
	"rewind": [
		{ "speaker": "Tutoh", "anim": "Smirk", "text": "Hail, Grand Majesty Of Evil, Lord Dungeonkin." },
		{ "speaker": "Tutoh", "anim": "Default", "text": "There's—" },
		{ "speaker": "DungeonKin", "anim": "Default", "text": "I know." },
		{ "speaker": "Tutoh", "anim": "Shocked", "text": "Oh..." },
		{ "speaker": "Tutoh", "anim": "Shocked", "text": "I did see a different gleam in your eye..." },
		{ "speaker": "Tutoh", "anim": "Smirk", "text": "I believe in you, Grand Majesty. Even multi-tasking as you are, they won't stand a chance. Just give it another shot." },
		{ "speaker": "DungeonKin", "anim": "Thinking", "text": "..Gather the troops." },
	],
	"end": [
		{ "speaker": "Tutoh", "anim": "Default", "text": "Servants of The Dungeon..." },
		{ "speaker": "Tutoh", "anim": "Smirk", "text": "Your Lord summons you. He has something important to say." },
		{ "speaker": "Tutoh", "anim": "Default", "text": "Report to his quarters..." },
	],
}

var speaker_names = {
	"Tutoh": "Sir Tutoh-Rheal",
	"DungeonKin": "Lord Dungeonkin"
}

var current_group: Array = []
var current_index: int = 0
var is_active: bool = false
var is_typing: bool = false
var on_finished: Callable

const CHARS_PER_SECOND = 30

func _ready() -> void:
	visible = false
	ContinueIcon.visible = false
	SkipButton.visible = false
	SkipButton.pressed.connect(finish)

func _input(event: InputEvent) -> void:
	if not is_active:
		return
	var clicked = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	var entered = event is InputEventKey and event.pressed and event.keycode == KEY_ENTER
	if not clicked and not entered:
		return

	if is_typing:
		skip_typing()
	else:
		advance()

func start(group_name: String, finished_callback: Callable = Callable()) -> void:
	if not dialogue_groups.has(group_name):
		print("Dialogue group not found: ", group_name)
		return

	current_group = dialogue_groups[group_name]
	current_index = 0
	is_active = true
	on_finished = finished_callback
	visible = true
	show_line()

func advance() -> void:
	current_index += 1
	if current_index >= len(current_group):
		finish()
	else:
		show_line()

func show_line() -> void:
	var line = current_group[current_index]
	var speaker = line["speaker"]
	var anim = line["anim"]
	var full_text = line["text"]

	ContinueIcon.visible = false

	if current_index >= 1:
		SkipButton.visible = true

	NameLabel.text = speaker_names.get(speaker, speaker)

	Tutoh.visible = speaker == "Tutoh"
	DungeonKin.visible = speaker == "DungeonKin"

	if speaker == "Tutoh":
		if Tutoh.sprite_frames.has_animation(anim):
			Tutoh.play(anim)
	elif speaker == "DungeonKin":
		if DungeonKin.sprite_frames.has_animation(anim):
			DungeonKin.play(anim)

	type_text(full_text)

func type_text(full_text: String) -> void:
	is_typing = true
	TextLabel.visible_characters = -1
	TextLabel.set_fit_text(full_text)
	await get_tree().process_frame
	TextLabel.visible_characters = 0
	var total_chars = len(full_text)
	var interval = 1.0 / CHARS_PER_SECOND

	for i in range(total_chars):
		if not is_typing:
			break
		TextLabel.visible_characters = i + 1
		await get_tree().create_timer(interval).timeout

	finish_typing(full_text)

func skip_typing() -> void:
	is_typing = false
	TextLabel.visible_characters = -1
	ContinueIcon.visible = true

func finish_typing(_full_text: String) -> void:
	if not is_typing:
		return
	is_typing = false
	TextLabel.visible_characters = -1
	ContinueIcon.visible = true

func finish() -> void:
	is_active = false
	is_typing = false
	visible = false
	ContinueIcon.visible = false
	SkipButton.visible = false
	TextLabel.text = ""
	TextLabel.visible_characters = -1
	NameLabel.text = ""
	Tutoh.visible = false
	DungeonKin.visible = false
	current_group = []
	current_index = 0
	if on_finished.is_valid():
		on_finished.call()
