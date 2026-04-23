shader_type canvas_item;

uniform vec4 core_color : source_color = vec4(1.0, 0.95, 0.95, 1.0);
uniform vec4 glow_color : source_color = vec4(1.0, 0.1, 0.1, 1.0);
uniform float glow_strength = 0.8;
uniform float flicker_strength = 0.08;
uniform float speed = 8.0;

void fragment() {
    vec2 uv = UV;

    float dist_from_center = abs(uv.y - 0.5) * 2.0;

    float core = smoothstep(0.25, 0.0, dist_from_center);
    float glow = smoothstep(1.0, 0.15, dist_from_center);

    float flicker = 1.0 + sin(TIME * speed + uv.x * 10.0) * flicker_strength;

    vec4 color = glow_color * glow * glow_strength;
    color += core_color * core;

    color.rgb *= flicker;
    color.a = max(core * core_color.a, glow * glow_color.a * 0.6);

    COLOR = color;
}