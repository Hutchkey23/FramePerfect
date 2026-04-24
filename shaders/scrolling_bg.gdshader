shader_type canvas_item;

uniform vec2 scroll_speed = vec2(-0.05, 0.0);
uniform vec2 texture_scale = vec2(1.0, 1.0);
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec2 uv = UV * texture_scale;
	uv += scroll_speed * TIME;
	
	vec4 tex = texture(TEXTURE, fract(uv));
	COLOR = tex * tint_color;
}