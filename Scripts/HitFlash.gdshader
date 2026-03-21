shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Outline
	float outline = 0.0;
	vec2 size = outline_width / vec2(textureSize(TEXTURE, 0));
	outline += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
	outline += texture(TEXTURE, UV - vec2(size.x, 0.0)).a;
	outline += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
	outline += texture(TEXTURE, UV - vec2(0.0, size.y)).a;
	outline = clamp(outline, 0.0, 1.0);
	outline *= (1.0 - tex.a); // only where sprite is transparent

	// Flash
	vec4 solid = vec4(flash_color.rgb, tex.a);
	vec4 flashed = mix(tex, solid, flash_amount);

	COLOR = mix(flashed, outline_color, outline);
}