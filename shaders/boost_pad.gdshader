shader_type canvas_item;

uniform vec4 target_color : source_color = vec4(1.0, 0.95, 0.0, 1.0);
uniform float tolerance = 0.25;
uniform float glow_strength = 1.8;
uniform float pulse_speed = 4.0;
uniform float pulse_amount = 0.25;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float color_distance = distance(tex.rgb, target_color.rgb);
	float mask = 1.0 - smoothstep(0.0, tolerance, color_distance);

	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_amount;

	vec3 boosted = tex.rgb * glow_strength * pulse;

	COLOR = vec4(mix(tex.rgb, boosted, mask), tex.a);
}