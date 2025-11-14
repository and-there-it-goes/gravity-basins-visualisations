shader_type canvas_item;
render_mode blend_mix,unshaded,world_vertex_coords;

group_uniforms VISUALS;
uniform float visibility_factor = 0.0;
group_uniforms;

group_uniforms BODIES;
uniform vec2 body1 = vec2(557., 139.);
uniform vec2 body2 = vec2(271., 414.);
uniform vec2 body3 = vec2(848., 460.);


varying vec2 pos;


group_uniforms SIMULATION;
uniform vec2 init_v = vec2(0.0, 0.0);
group_uniforms;

group_uniforms DO_NOT_MODIFY;
uniform float epsilon = 1e-5;
uniform float rmul = 0.00005; // offsets multiplier
group_uniforms;

group_uniforms SIMULATION;
uniform float d = 0.001; // drag force (factor/tick)
uniform float t = 0.0005; // delta time (arbitrary)
varying flat float tSquared;
uniform int steps = 4000; // maximum simulation steps
group_uniforms;


void vertex() { pos = VERTEX; tSquared = t*t; }


group_uniforms VISUALS;
// recommended to use 100%-saturation colours here
uniform vec3 color1 = vec3(0.96484375, 0.94140625, 0.41406250);
uniform vec3 color2 = vec3(0.00000000, 0.77343750, 0.63281250);
uniform vec3 color3 = vec3(0.00000000, 0.45703125, 0.99609375);

uniform int visualisation_type0 = 0;
uniform int visualisation_type1 = 1;
uniform float visualisation_mix = 0.9;
group_uniforms;

vec3 lab_to_xyz(vec3 lab) {
	float L = lab.s;
	float a = lab.t;
	float b = lab.p;
	
	float var_Y = (L + 16.0) / 116.0;
	float var_X = a / 500.0 + var_Y;
	float var_Z = var_Y - b / 200.0;

	if (pow(var_Y, 3.0) > 0.008856) var_Y = pow(var_Y, 3.0);
	else var_Y = (var_Y - 16. / 116.) / 7.787;
	if (pow(var_X, 3.0) > 0.008856) var_X = pow(var_X, 3.0);
	else var_X = (var_X - 16. / 116.) / 7.787;
	if (pow(var_Z, 3.0) > 0.008856) var_Z = pow(var_Z, 3.0);
	else var_Z = ( var_Z - 16. / 116. ) / 7.787;
	
	return vec3(var_X, var_Y, var_Z);
}

vec3 xyz_to_rgb(vec3 xyz) {
	float var_X = xyz.x;
	float var_Y = xyz.y;
	float var_Z = xyz.z;
	
	float var_R = var_X *  3.2406 + var_Y * -1.5372 + var_Z * -0.4986;
	float var_G = var_X * -0.9689 + var_Y *  1.8758 + var_Z *  0.0415;
	float var_B = var_X *  0.0557 + var_Y * -0.2040 + var_Z *  1.0570;

	if (var_R > 0.0031308) var_R = 1.055 * pow(var_R, (1. / 2.4)) - 0.055;
	else var_R = 12.92 * var_R;
	if (var_G > 0.0031308) var_G = 1.055 * pow(var_G, (1. / 2.4)) - 0.055;
	else var_G = 12.92 * var_G;
	if (var_B > 0.0031308) var_B = 1.055 * pow(var_B, (1. / 2.4)) - 0.055;
	else var_B = 12.92 * var_B;
	
	return vec3(var_R, var_G, var_B);
}

vec3 lab_to_rgb(vec3 lab) {
	return xyz_to_rgb(lab_to_xyz(lab));
}


vec3 visualise(in int viz_id, in vec2 start, in vec2 p, in vec2 v, in float sum_delta_va, in float va, in float d1, in float d2, in float d3, in int closest_body_changes, in float dist_traveled, in float dist_traveled_r, in vec2 sum_dv, in vec2 sum_dvr, in float sum_scalar_dv, in float sum_scalar_dvr) {
	switch (viz_id) {
		case 0:
			vec3 c = vec3(0.0);
			if (d1 <= d2 && d1 <= d3) c += color1;
			if (d2 <= d1 && d2 <= d3) c += color2;
			if (d3 <= d1 && d3 <= d2) c += color3;
			return c;
		case 1:
			float L = sum_delta_va / TAU * 4.;
			vec2 ab = normalize(vec2(1.0, 0.2)) * 50.;
			vec3 c = lab_to_rgb(vec3(L, ab));
			return c;
		case 2:
			float L = 50.; //clamp(100. - min(min(d1, d2), d3) / 8., 0., 100.);
			vec2 b = start;
			if (d1 <= d2 && d1 <= d3) b = body1;
			if (d2 <= d1 && d2 <= d3) b = body2;
			if (d3 <= d1 && d3 <= d2) b = body3;
			vec2 o = start - b;
			vec2 ab = normalize(o) * 100.;
			vec3 c = lab_to_rgb(vec3(L, ab));
			return c;
		case 3:
			return (
				vec3(0.0, 0.0, 0.2) * clamp(float(closest_body_changes - 1), 0., 5.) +
				vec3(0.0, 0.2, 0.0) * clamp(float(closest_body_changes - 6), 0., 5.)
			);
		case 4:
			float L = 50.;
			vec2 ab = sum_dv * vec2(-1.0, 1.0) / 10.;
			vec3 c = clamp(lab_to_rgb(vec3(L, ab)), vec3(0.0), vec3(1.0));
			return c;
		case 5:
			float L = length(sum_dvr) * 2.;
			vec2 ab = sum_dvr * vec2(1.0, 1.0) * 3.;
			vec3 c = clamp(lab_to_rgb(vec3(L, ab)), vec3(0.0), vec3(1.0));
			return c;
		case 6:
			float L = length(sum_scalar_dv) / 1600.;
			vec2 ab = normalize(vec2(1.0, -0.3)) * 50.;
			vec3 c = clamp(lab_to_rgb(vec3(L, ab)), vec3(0.0), vec3(1.0));
			return c;
		case 7:
			float L = length(sum_scalar_dvr) / 1.8 - 60.;
			vec2 ab = normalize(vec2(1.0, -0.3)) * 50.;
			vec3 c = clamp(lab_to_rgb(vec3(L, ab)), vec3(0.0), vec3(1.0));
			return c;
		case 8:
			return lab_to_rgb(vec3(
				dist_traveled / 20. - 40.,
				normalize(vec2(0.2, -1.0)) * 50.0
			));
		case 9:
			vec2 b = start;
			if (d1 <= d2 && d1 <= d3) b = body1;
			if (d2 <= d1 && d2 <= d3) b = body2;
			if (d3 <= d1 && d3 <= d2) b = body3;
			vec2 o = start - b;
			return lab_to_rgb(vec3(
				dist_traveled / length(o) * 2.,
				normalize(vec2(0.2, -1.0)) * 50.0
			));
		case 10:
			return lab_to_rgb(vec3(
				dist_traveled_r * 8.,
				normalize(vec2(0.2, -1.0)) * 50.0
			));
		case 11:
			vec2 b = start;
			if (d1 <= d2 && d1 <= d3) b = body1;
			if (d2 <= d1 && d2 <= d3) b = body2;
			if (d3 <= d1 && d3 <= d2) b = body3;
			vec2 o = start - b;
			return lab_to_rgb(vec3(
				dist_traveled_r / length(o) * 1200.,
				normalize(vec2(0.2, -1.0)) * 50.0
			));
		default:
			return vec3(0.0);
	}
}

vec3 simulate(in vec2 start, in vec2 uv) {
	
	vec2 p = start;
	vec2 v = init_v;
	
	bool exited = false;
	
	
	vec2 sum_dv = vec2(0.0);
	vec2 sum_dvr = vec2(0.0);
	float sum_scalar_dv = 0.0;
	float sum_scalar_dvr = 0.0;
	float dist_traveled = 0.0;
	float dist_traveled_r = 0.0;
	
	float sum_delta_va = 0.0;
	float va = TAU * -1000.0;
	
	int closest_body = -1;
	int closest_body_changes = 0;
	
	for (int stepCount = 0; stepCount < steps; stepCount++) {
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
		p += s;
		v += dv;
		if (v.x != 0.0 || v.y != 0.0) {
			v -= v * d;
			
			float va1 = atan(v.y, v.x);
			if (va > -TAU) {
				sum_delta_va += abs(mod((va1 - va) + PI, TAU) - PI);
			}
			va = va1;
			
		}
		float r = min(min(r1, r2), r3);
		dist_traveled += length(s);
		dist_traveled_r += length(s) * r;
		sum_dv += dv;
		sum_dvr += dv * r;
		sum_scalar_dv += length(dv);
		sum_scalar_dvr += length(dv) * r;
		
		int closest_body_1 = -1;
		
		if (r1 <= r2 && r1 <= r3) closest_body_1 = 1;
		if (r2 <= r1 && r2 <= r3) closest_body_1 = 2;
		if (r3 <= r1 && r3 <= r2) closest_body_1 = 3;
		
		if (closest_body_1 != closest_body) {
			closest_body = closest_body_1;
			closest_body_changes++;
		}
		
	}
	
	float d1 = distance(p, body1);
	float d2 = distance(p, body2);
	float d3 = distance(p, body3);
	
	vec3 c0 = visualise(visualisation_type0, start, p, v, sum_delta_va, va, d1, d2, d3, closest_body_changes, dist_traveled, dist_traveled_r, sum_dv, sum_dvr, sum_scalar_dv, sum_scalar_dvr);
	vec3 c1 = visualise(visualisation_type1, start, p, v, sum_delta_va, va, d1, d2, d3, closest_body_changes, dist_traveled, dist_traveled_r, sum_dv, sum_dvr, sum_scalar_dv, sum_scalar_dvr);
	
	return mix(c0, c1, visualisation_mix);
	
}


void fragment() {
	vec3 result = vec3(0.2);
	if (visibility_factor > 0.0001) {
		vec3 sim_result = simulate(pos, UV);
		if (visibility_factor < 0.9999)
			result = mix(result, sim_result, visibility_factor);
		else result = sim_result;
	}
	COLOR = vec4(result, 1.0);
	float d1 = distance(pos, body1);
	float d2 = distance(pos, body2);
	float d3 = distance(pos, body3);
	float f = (12.0 - min(min(d1, d2), d3)) / 2.0;
	COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, 1.0), clamp(f, 0.0, 1.0));
	float f2 = (8.0 - min(min(d1, d2), d3)) / 2.0;
	COLOR = mix(COLOR, vec4((d1 <= d2 && d1 <= d3 ? color1 : (d2 <= d3 ? color2 : color3)), 1.0), clamp(f2, 0.0, 1.0));
}
