// Source: https://github.com/GDQuest/godot-shaders/blob/master/godot/Shaders/dissolve2D.shader

shader_type canvas_item;

uniform sampler2D dissolve_texture;
uniform float dissolve_amount : hint_range(0, 1);

void fragment() {
	vec4 out_color = texture(TEXTURE, UV);
	float sample = texture(dissolve_texture, UV).r;
	COLOR = vec4(out_color.rgb, smoothstep(dissolve_amount, dissolve_amount, sample) * out_color.a);
}