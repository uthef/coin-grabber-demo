shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform float strength: hint_range(0.0, 1.0, 0.1);

void vertex() {
	
}

void fragment() {
	float offset = strength * 3.;
	vec2 halfpixel = SCREEN_PIXEL_SIZE / 2.0;

	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);

	vec4 sum = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-halfpixel.x * 2.0, 0.0) * offset);
	sum += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-halfpixel.x, halfpixel.y) * offset) * 2.0;
	sum += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, halfpixel.y * 2.0) * offset);
	sum += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(halfpixel.x, halfpixel.y) * offset) * 2.0;
	sum += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(halfpixel.x * 2.0, 0.0) * offset);
	sum += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(halfpixel.x, -halfpixel.y) * offset) * 2.0;
	sum += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, -halfpixel.y * 2.0) * offset);
	sum += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-halfpixel.x, -halfpixel.y) * offset) * 2.0;

	COLOR = sum / 12.0;
	COLOR = mix(COLOR, vec4(COLOR.g, COLOR.g, COLOR.g, 1.0) * vec4(.5, .5, .5, 1), strength);
}
