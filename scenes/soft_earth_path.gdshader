shader_type canvas_item;

uniform vec4 target_sand_color : source_color = vec4(0.91, 0.76, 0.57, 1.0);
uniform float grain_strength : hint_range(0.0, 0.1) = 0.025;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 tex_col = texture(TEXTURE, UV);
	// Pertahankan transparansi tile sambil menghaluskan warna tanah jalan menjadi pasir hangat
	vec2 pixel_cell = floor(world_pos / 3.5);
	float n = fract(sin(dot(pixel_cell, vec2(12.9898, 78.233))) * 43758.5453);
	float grain = (n - 0.5) * 2.0 * grain_strength;
	vec3 mixed = mix(tex_col.rgb, target_sand_color.rgb, 0.88) + vec3(grain);
	COLOR = vec4(clamp(mixed, 0.0, 1.0), COLOR.a);
}
