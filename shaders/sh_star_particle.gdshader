shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
	//COLOR.rgb = vec3(0.5, 0.5, 0.5);
	COLOR.rgb = vec3(1.0, 1.0 , 1.0 - INSTANCE_CUSTOM.z);
	COLOR.rgb = COLOR.rgb + vec3(1.0, 0.0, 0.0);
	//POINT_SIZE = 0.1;
}

void fragment() {
	ALBEDO = COLOR.rgb;

	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
