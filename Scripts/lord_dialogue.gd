extends TextureRect

@export var dialogue_label: NodePath
@export var seconds_per_character: float = 0.04
@export var pause_between_lines: float = 1.2

var _lines: Array[String] = [
	"Hail.",
	"The crisis has been averted.",
	"My Dungeon still stands.",
	"Another calamity stalled, as many have been before, in my time.",
	"It's been a pleasure.",
	"You have all proven yourselves to be applicable servants.",
	"That being said...",
	"With so vast a number under my employ...",
	"And the ever rising cost of soldiery, of lures, of stages...",
	"We find ourselves running at a loss here...",
	"Therefore, as heartwrenching as it is to say... You're all...",
	"Fired.",
	"...Nay, it's not really heartwrenching at all.",
]

var _label: Label
var _current_line: int = 0
var _typing: bool = false

func _ready() -> void:
	_label = get_node(dialogue_label)
	visible = true
	_play_next_line()

func _play_next_line() -> void:
	if _current_line >= _lines.size():
		visible = false
		return
	_typing = true
	_label.text = _lines[_current_line]
	_label.visible_characters = 0
	var full_length: int = _lines[_current_line].length()
	for i in range(full_length + 1):
		_label.visible_characters = i
		await get_tree().create_timer(seconds_per_character).timeout
	_typing = false
	_current_line += 1
	await get_tree().create_timer(pause_between_lines).timeout
	_play_next_line()
