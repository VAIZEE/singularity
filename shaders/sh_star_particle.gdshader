shader_type spatial;

// Called for every vertex the material is visible on.
void vertex() {
	
	
	//Set render size based on current Velocity read from custom data that comes from process shader
	POINT_SIZE = INSTANCE_CUSTOM.x;
	
	//TODO point color based on size to blue shift
	
	//Set color based on current Velocity read from custom data that comes from process shader
	COLOR.rgb = vec3(1.0, 1.0 , 1.0 - INSTANCE_CUSTOM.z);
	COLOR.rgb = COLOR.rgb + vec3(1.0, 0.0, 0.0);
	

}

// Called for every pixel the material is visible on.
void fragment() {
	ALBEDO = COLOR.rgb;
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
