shader_type particles;
render_mode disable_force,disable_velocity;

group_uniforms TIME_SPEED;
uniform float tmul = 0.1;
group_uniforms;

group_uniforms DO_NOT_MODIFY;
uniform vec2 body1 = vec2(557., 139.);
uniform vec2 body2 = vec2(271., 414.);
uniform vec2 body3 = vec2(848., 460.);

uniform vec2 init_v = vec2(0.0, 0.0);

uniform float epsilon;
uniform float rmul;
uniform float d;
uniform float t;
uniform float tSquared;

uniform vec2 start_pos = vec2(0.0);
group_uniforms;

void start() {
	USERDATA1.xy = start_pos;
	USERDATA1.zw = vec2(0.0, 1.0);
	USERDATA2 = vec4(init_v, 0.0, 0.0);
	TRANSFORM = mat4(vec4(1.0, 0.0, 0.0, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), USERDATA1);
	COLOR = vec4(1.0, 1.0, 1.0, 0.0);
}

void process() {

	vec2 p = USERDATA1.xy;
	vec2 v = USERDATA2.xy;
	float deltaT = DELTA * tmul;

	for (float totalT = 0.0; totalT < deltaT; totalT += t) {
		vec2 o1 = (p - body1) * rmul;
		vec2 o2 = (p - body2) * rmul;
		vec2 o3 = (p - body3) * rmul;
		float r1s = o1.x * o1.x + o1.y * o1.y;
		float r2s = o2.x * o2.x + o2.y * o2.y;
		float r3s = o3.x * o3.x + o3.y * o3.y;
		float r1 = sqrt(r1s);
		float r2 = sqrt(r2s);
		float r3 = sqrt(r3s);
		vec2 gn = (-o1 / r1) / (r1s + epsilon) + (-o2 / r2) / (r2s + epsilon) + (-o3 / r3) / (r3s + epsilon);
		vec2 s = v * t + 0.5 * gn * tSquared;
		vec2 dv = gn * t;
		if (min(min(r1, r2), r3) <= 0.002) {
			USERDATA2.z -= t;
			if (USERDATA2.z <= 0.0) {
				ACTIVE = false;
				COLOR = vec4(0.0);
			}
		} else {
			USERDATA2.z = clamp(USERDATA2.z + t, 0.0, 2.0);
		}
		p += s;
		v += dv;
		if (v.x != 0.0 || v.y != 0.0) {
			v -= v * d;
		}
	}

	if (USERDATA2.z > 0.0) {
		COLOR = vec4(1.0, 1.0, 1.0, clamp(USERDATA2.z * 3., 0.0, 1.0));
	}

	USERDATA1.xy = p;
	USERDATA2.xy = v;
	TRANSFORM = mat4(vec4(1.0, 0.0, 0.0, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), USERDATA1);

}