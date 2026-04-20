shader_type canvas_item;

uniform vec4 pulse_color : source_color = vec4(1.0, 0.22, 0.45, 1.0);
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.16;
uniform float pulse_speed : hint_range(0.1, 10.0) = 2.5;
uniform float center_glow_strength : hint_range(0.0, 1.0) = 0.08;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float pulse = (sin(TIME * pulse_speed) + 1.0) * 0.5;
	float amount = pulse * pulse_strength;

	vec2 centered_uv = UV - vec2(0.5);
	float dist = length(centered_uv);
	float glow = smoothstep(0.7, 0.0, dist) * center_glow_strength * pulse;

	vec3 rgb = mix(tex.rgb, pulse_color.rgb, amount + glow);

	COLOR = vec4(rgb, tex.a) * COLOR;
}