shader_type particles;
//https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html

uniform vec3 origin;
uniform float start_time;
uniform float expansion_speed_factor = 1.0;


const float black_holes_formed_value = -1.0;
const float atracted_by_black_hole = -2.0;

const float ROTATION_SPEED = 8.0;
const float REVERSE_DURATION = 4.0;
const float REVERSE_SPEED = 4.0;
const float G = 6.67430e-11;
const float MAX_MASS = 10.0;
const float MAX_SIZE = 3.0;

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
	//Set particle position to the given origin
	TRANSFORM[3].xyz = origin;
	
	//Give the Particle a random velocity out of evenly distributed pool of possibilities
	VELOCITY = random_velocity_in_sphere(NUMBER, RANDOM_SEED) * expansion_speed_factor;
	
	//Initializ the custom vector to be just zeros
	CUSTOM.xyzw = vec4(0.0);
	
	//Get random value from 0 - 1 for further interpolation purposes
	float random_0_1 = rand_from_seed(hash(NUMBER + uint(72) + RANDOM_SEED));
	
	//Linearly Interpolated random mass from 1 to MAX_MASS
	CUSTOM.w = mix(1.0, MAX_MASS, random_0_1);
	
	//Linearly Interpolated random size from 1 to 3
	CUSTOM.x = mix(1.0, MAX_SIZE, random_0_1);
}

// Called every frame on existing particles (according to the Fixed FPS property).
void process() {
	//Calculate runtime of shader programm
	float runtime = TIME - start_time;
	float time_left = LIFETIME - runtime;
	bool start_reverse = time_left <= (REVERSE_DURATION);
	bool time_over = time_left <= 0.0;
	
	if(INDEX == uint(0)){
		//If need code once each rotation
	}
	CUSTOM.z = length(ATTRACTOR_FORCE);
	
	
	
	if(start_reverse) {
		vec3 dir = origin - TRANSFORM[3].xyz;
		VELOCITY = dir * REVERSE_SPEED;
		
		if(length(dir) < 0.0001 || time_over) {
			ACTIVE = false;
		}
		//When Stars/Black Holes start forming
	} else if(runtime > 2.0) {
		bool in_black_hole_range = length(ATTRACTOR_FORCE) > 0.0;
		//Once per Simulation
		//if(CUSTOM.x != black_holes_formed_value) {
			//CUSTOM.x = black_holes_formed_value;
			//VELOCITY = vec3(0);
		//}
		
		// Only if in attracktor range execute this line to safe execution
		if(in_black_hole_range){
			
			//If gets in range of atractor apply rotation
			if(CUSTOM.y != atracted_by_black_hole) {
				CUSTOM.y = atracted_by_black_hole;
				vec3 dir_origin = ATTRACTOR_FORCE;
				dir_origin.y = 0.0;
				dir_origin = normalize(dir_origin);
				VELOCITY += normalize(cross(dir_origin, vec3(0,1,0))) * ROTATION_SPEED * DELTA;
			}
			//add force to velocity in concideration of bodies mass and frame time
			VELOCITY += ATTRACTOR_FORCE / CUSTOM.w * DELTA;
		}
	} 

	//General Update
	TRANSFORM[3].xyz += VELOCITY * DELTA;
}
