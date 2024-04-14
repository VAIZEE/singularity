shader_type particles;
//https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html

uniform vec3 origin;
uniform float start_time;
uniform float expansion_speed_factor;

const float G = 6.67430e-11;
const float black_holes_formed_value = -1.0;
const float atracted_by_black_hole = -2.0;
const float has_ended = -2.0;
const float universe_spin_factor = 8.0;

const float TRUE = 1.0;
const float FALSE = 0.0;

//function for random value
float rand_from_seed(in uint seed) {
  int k;
  int s = int(seed);
  if (s == 0)
    s = 305420679;
  k = s / 127773;
  s = 16807 * (s - k * 127773) - 2836 * k;
  if (s < 0)
    s += 2147483647;
  seed = uint(s);
  return float(seed % uint(65536)) / 65535.0;
}
//function for random value
uint hash(uint x) {
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = (x >> uint(16)) ^ x;
  return x;
}

vec3 random_vel_in_cube(uint number, uint random_seed){
	uint alt_seed1 = hash(number + uint(1) + random_seed);
	uint alt_seed2 = hash(number + uint(27) + random_seed);
	uint alt_seed3 = hash(number + uint(43) + random_seed);

	vec3 random_vel = vec3(rand_from_seed(alt_seed1) * 2.0 - 1.0,
                     rand_from_seed(alt_seed2) * 2.0 - 1.0,
                     rand_from_seed(alt_seed3) * 2.0 - 1.0);
	return random_vel;
}

vec3 random_velocity_in_sphere(uint number, uint random_seed) {
	uint alt_seed1 = hash(number + uint(27) + random_seed);
	uint alt_seed2 = hash(number + uint(43) + random_seed);
	uint alt_seed3 = hash(number + uint(111) + random_seed);
	
	//Calculate evenly distibuted random point on Sphere 
	//from https://stackoverflow.com/questions/8839086/how-to-randomize-points-on-a-sphere-surface-evenly
	float z = rand_from_seed(alt_seed1) * 2.0 - 1.0;
	float rxy = sqrt(1.0 - z*z);
	float phi = rand_from_seed(alt_seed2) * 2.0 * PI;
	float x = rxy * cos(phi);
	float y = rxy * sin(phi);
	
	//Return velocity between 0.1 and 1.1 so no clump in middle
	return normalize(vec3(x, y, z)) * (rand_from_seed(alt_seed3) + 0.1); 
}


// Called when a particle is spawned.
void start() {
	VELOCITY = random_velocity_in_sphere(NUMBER, RANDOM_SEED) * expansion_speed_factor;
	TRANSFORM[3].xyz = origin;
	CUSTOM.xyzw = vec4(1.0, 1.0, 0.0, 0.0);
}

// Called every frame on existing particles (according to the Fixed FPS property).
void process() {
	//Calculate runtime of shader programm
	float runtime = TIME - start_time;
	float time_left = LIFETIME - runtime;
	bool end_time_reached = time_left < 2.0;
	
	if(time_left <= 0.0) {
		ACTIVE = false;
	}

	if(INDEX == uint(0)){
		//If need code once each rotation
	}
	CUSTOM.z = length(ATTRACTOR_FORCE);
	
	
	if(CUSTOM.z != has_ended && end_time_reached) {
		vec3 dir = origin - TRANSFORM[3].xyz;
		VELOCITY = normalize(dir) * LIFETIME;
		CUSTOM.z = has_ended;
	}
	
	//When Stars/Black Holes start forming
	if(runtime > 2.0 && !end_time_reached) {
		
		//Once per Simulation
		if(CUSTOM.x != black_holes_formed_value) {
			CUSTOM.x = black_holes_formed_value;
			//VELOCITY = vec3(0);
		}
		
		//If gets in range of atractor apply rotation
		if(length(ATTRACTOR_FORCE) > 0.0 && CUSTOM.y != atracted_by_black_hole){
			CUSTOM.y = atracted_by_black_hole;
			vec3 dir_origin = ATTRACTOR_FORCE;
			dir_origin.y = 0.0;
			dir_origin = normalize(dir_origin);
			VELOCITY += normalize(cross(dir_origin, vec3(0,1,0))) * universe_spin_factor * DELTA;
		}
		
		// Only if in attracktor range execute this line to safe execution
		if(length(ATTRACTOR_FORCE) > 0.0){
			
			VELOCITY += ATTRACTOR_FORCE * DELTA;
		}
	} 

	//General Update
	TRANSFORM[3].xyz += VELOCITY * DELTA;
}
