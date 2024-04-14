extends GPUParticlesAttractorSphere3D

var mass : float
var velocity : Vector3

const G = 6.67430e-11;

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
		self.name = "Black Hole"
		self.position = Vector3(0, 0, 0)
		self.radius = 5.4
		self.strength = 0.8 #0.8
		self.attenuation = 0.1 #0.1
		self.velocity = Vector3(rng.randf_range(-1,1),rng.randf_range(-1,1),rng.randf_range(-1,1)).normalized()
		self.mass = 30000000




func apply_force_from(other, delta):

	var dir : Vector3 = other.global_position - self.global_position
	var dist = dir.length() + 0.1
	
	#In reality 1/mass1 * (G * mass1 * mass2) / (dist * dist) so we can take out mass1
	var forceMagnitude = (G * other.mass) / (dist * dist);
	velocity += (dir.normalized() * forceMagnitude) * delta;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
