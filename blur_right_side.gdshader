shader_type canvas_item;
render_mode unshaded,blend_mix;

uniform sampler2D screen_tex : hint_screen_texture;

void fragment() {
	float blur = smoothstep(0.0, 0.5, UV.x);
	float count = float(24 * 2 + 1) * float(12 * 2 + 1) * 2.;
	vec3 c = vec3(0.5) * count / 2.;
	for (int x = -24; x <= 24; x++) {
		for (int y = -12; y <= 12; y++) {
			c += texture(screen_tex, clamp(SCREEN_UV + SCREEN_PIXEL_SIZE * vec2(float(x), float(y)), SCREEN_PIXEL_SIZE, vec2(1.) - SCREEN_PIXEL_SIZE)).rgb;
		}
	}
	COLOR = vec4(mix(texture(screen_tex, SCREEN_UV).rgb, c / count, blur), 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
