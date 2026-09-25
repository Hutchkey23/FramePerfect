shader_type canvas_item;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(0.22, 0.22, 0.22, tex.a);
}