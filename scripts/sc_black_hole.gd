extends GPUParticlesAttractorSphere3D

var mass : float
var velocity : Vector3
var expansion_speed_factor : float
var last_pos : Vector3
var target_size : float


const MAX_START_SIZE = 3.0
const MIN_START_SIZE = 1.0
const G = 6.67430e-11;

var rng = RandomNumberGenerator.new()

const COLLISION_MASK := 0b0000_0000_0000_0000_0000_0000_0000_0010
const COLLISION_LAYER := 0b0000_0000_0000_0000_0000_0000_0000_0010

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area3D.collision_layer = COLLISION_LAYER
	$Area3D.collision_mask = COLLISION_MASK
	
	self.name = "Black Hole"
	#self.position = Vector3(0, -1, -1)
	self.last_pos = self.position
	self.radius = 0.0
	self.target_size = rng.randf_range(MAX_START_SIZE, MIN_START_SIZE)
	self.strength = 0.8 #0.0 - 0.8
	self.attenuation = 0.1 #0.1
	self.velocity = Vector3(rng.randf_range(-1,1),rng.randf_range(-1,1),rng.randf_range(-1,1)).normalized()
	self.mass = 30000000

	#TODO mass -> radius -> strength -> lifetime 
	#TODO gradual increase of power and radius?
	#TODO merge with other black holes for more power
	#TODO find our maximum attractor count and hold that count by creating a new one after merge or death
	#TODO simulate death? of stars


func apply_force_from(other, delta):

	var dir : Vector3 = other.global_position - self.global_position
	var dist = dir.length() + 0.1
	
	#In reality 1/mass1 * (G * mass1 * mass2) / (dist * dist) so we can take out mass1
	var forceMagnitude = (G * other.mass) / (dist * dist);
	velocity += (dir.normalized() * forceMagnitude) * delta;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(self.radius < self.target_size):
		self.radius += self.target_size / 200
		
	self.last_pos = self.global_position
	
	#Update velocity
	#var b_holes = get_tree().get_nodes_in_group("black_holes")
	#for b_hole in b_holes:
		#if(self != b_hole):
			#self.apply_force_from(b_hole, delta)	
	
	
	#Update Position
	self.global_position += self.velocity * delta * expansion_speed_factor
	pass
