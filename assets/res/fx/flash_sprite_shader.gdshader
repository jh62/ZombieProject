shader_type canvas_item;

uniform vec4 hit_color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float hit_strength : hint_range(0.0,1.0) = 0.0;

void fragment() {
	vec4 custom_color = texture(TEXTURE, UV);
	custom_color.rgb = mix(custom_color.rgb, hit_color.rgb, hit_strength);
	COLOR = custom_color;
}