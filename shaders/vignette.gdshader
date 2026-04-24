shader_type canvas_item;

uniform float vignette_strength : hint_range(0.0, 1.0) = 0.35;
uniform float vignette_radius : hint_range(0.0, 1.0) = 0.65;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 centered_uv = UV - vec2(0.5);
	float dist = length(centered_uv);

	float vignette = smoothstep(vignette_radius, 0.85, dist);
	float alpha = vignette * vignette_strength;

	COLOR = vec4(vignette_color.rgb, alpha);
}