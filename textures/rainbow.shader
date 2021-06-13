shader_type canvas_item;

vec4 rgba_to_hsva(vec4 rgba){
	//loat rad_60 = 60*(pi/180);
	vec3 rgb = vec3(rgba.r, rgba.g, rgba.b)/vec3(255.0, 255.0, 255.0);
	float alpha = ((2.0*rgb.r) - rgb.g - rgb.b)*0.5;
	float beta = (sqrt(3.0)/(2.0))*(rgb.g - rgb.b);
	float H = atan(beta, alpha);
	float C = sqrt(pow(alpha,2.0) + pow(beta,2.0));
	float V = max(rgb.r,(max(rgb.b,rgb.g)));
	float S;
	if (V == 0.0){
		S = 0.0;
	} else {
		S = C/V;
	}
	return vec4(H, S, V, rgba.a);
}

int calc_k(float n, float H){
	return int(n+(H/(0.0174)))%6;
}

float calc_f(float H, float S , float V , float n){
	int k = calc_k(n, H);
	return V - (V*S*float(max(0, min(k, min(4-k, 1)))));
}

vec4 hsva_to_rgba(vec4 hsva){
	vec3 hsv = vec3(hsva.x, hsva.y, hsva.z);
	vec3 rgb = vec3(
		calc_f(hsv.x, hsv.y, hsv.z, 5),
		calc_f(hsv.x, hsv.y, hsv.z, 3),
		calc_f(hsv.x, hsv.y, hsv.z, 1)
	);
	return vec4(rgb.r*255.0, rgb.g*255.0, rgb.b*255.0, hsva.w);
}

void fragment(){
	COLOR = texture(TEXTURE, UV);
	if (COLOR != vec4(0., 00., 0., 255.)) {
		vec4 hsva_in = rgba_to_hsva(COLOR);
		float H = hsva_in.x+(0.5*(SCREEN_UV.x+SCREEN_UV.y)-TIME/15.);
		vec4 hsva_out = vec4(H, 1, 1, hsva_in.w);
		COLOR = hsva_to_rgba(hsva_out);
	} 
}