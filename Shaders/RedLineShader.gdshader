shader_type spatial;

uniform vec4 color: hint_color = vec4(1.0, 0.0, 1.0, 0.0);

void fragment() {
	EMISSION = color.xyz;
	ALBEDO = color.xyz;
	ALPHA = UV.y;

	
}