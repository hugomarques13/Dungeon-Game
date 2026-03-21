extends Label

@export var min_font_size: int = 8
@export var max_font_size: int = 50

func set_fit_text(new_text: String) -> void:
	visible_characters = -1
	text = new_text
	fit_text()

func fit_text() -> void:
	var font = get_theme_font("font")
	var target_height = custom_minimum_size.y
	var target_width = size.x

	var size_val = max_font_size
	while size_val > min_font_size:
		var total_height = 0.0
		var words = text.split(" ")
		var line = ""
		for word in words:
			var test_line = (line + " " + word).strip_edges()
			var line_width = font.get_string_size(test_line, HORIZONTAL_ALIGNMENT_LEFT, -1, size_val).x
			if line_width > target_width and line != "":
				total_height += font.get_height(size_val)
				line = word
			else:
				line = test_line
		total_height += font.get_height(size_val)

		if total_height <= target_height:
			break
		size_val -= 1

	add_theme_font_size_override("font_size", size_val)
