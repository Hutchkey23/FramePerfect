shader_type canvas_item;

group_uniforms Shine;
uniform vec4 shine_color: source_color = vec4(0.75, 0.95, 1.0, 1.0);
uniform float shine_angle = -45.0;
uniform float shine_duration = 5.0;
uniform float shine_speed = 800.0;
uniform float shine_width = 10.0;
uniform float shine_strength = 0.25;
group_uniforms;

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;

	vec2 coord = SCREEN_UV / SCREEN_PIXEL_SIZE;

	float dist = abs(
		sin(radians(shine_angle)) * coord.x +
		cos(radians(shine_angle)) * coord.y +
		mod(TIME * shine_speed, shine_duration * shine_speed)
		- shine_duration * shine_speed * 0.5
	);

	float shine = smoothstep(shine_width, 0.0, dist);

	base.rgb += shine_color.rgb * shine * shine_strength * base.a;

	COLOR = base;
}