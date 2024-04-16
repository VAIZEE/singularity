extends Node3D
#https://en.wikipedia.org/wiki/Naked_singularity#:~:text=Hence%2C%20objects%20inside%20the%20event,be%20observable%20from%20the%20outside.

###############################Signals########################################
signal simulation_finished
signal simulation_started

###############################Preloads########################################
var particle_universe_shader = preload("res://shaders/sh_process_particle_universe.gdshader")
var black_hole = preload("res://scenes/scn_black_hole.tscn")


###############################Exports########################################
@export var SIZE : int = 1000
@export var STAR_COUNT : int = 3000000 #max for 90 fps was 5.000.000 rendered still
@export var LIFE_TIME : int = 10
@export var EXPANSION_SPEED_FACTOR : float = 1.0
@export var BLACK_HOLE_COUNT : int = 0


###############################OnReady########################################
@onready var animation_idle_singularity : AnimationPlayer = $AnimationPlayer
@onready var star_light : Node3D = $StarLight
@onready var singularity: MeshInstance3D = $center


var universe : GPUParticles3D = null
var simulation_paused : bool = false

###############################Engine Functions#################################

# Called when the node enters the scene tree for the first time.
func _ready():
	#Startup Pulsating Effect
	animation_idle_singularity.play("singularity_wobble")
	
	#Connect press to start trigger
	singularity.pressed.connect(start_simulation)

func _physics_process(delta):
	if(!singularity.visible):
		var b_holes = get_tree().get_nodes_in_group("black_holes")
		for b_hole in b_holes:
			for other_hole in b_holes:
				if(b_hole != other_hole):
					b_hole.apply_force_from(other_hole, delta)	
		
		for b_hole in b_holes:
			b_hole.global_position += b_hole.velocity * delta * EXPANSION_SPEED_FACTOR
	pass

func _exit_tree():
	pass

###############################Custom Functions#################################

func start_simulation():
	if(singularity.visible):
		singularity.visible = false
		star_light.visible = true

		universe = create_universe(LIFE_TIME, STAR_COUNT)
		self.add_child(universe)
		get_tree().create_timer(LIFE_TIME).timeout.connect(stop_simulation)
		
		simulation_started.emit()



func stop_simulation():
	singularity.visible = true
	star_light.visible = false
	delete_universe(universe)
	simulation_finished.emit()


func pause():
	simulation_paused = !simulation_paused
	universe.speed_scale = 0.0 if simulation_paused else 1.0

func create_universe(lifetime, star_count):
	#Load Star shader
	var emissive_material = ShaderMaterial.new()
	emissive_material.shader = load("res://shaders/sh_star_particle.gdshader")
	
	#Create Particle Mesh
	var mesh = PointMesh.new()
	mesh.material = emissive_material
	
	#Create GPU particle process Material
	var process_material = ShaderMaterial.new()
	process_material.set_shader(particle_universe_shader)
	process_material.set_shader_parameter("origin", Vector3(self.global_position))
	process_material.set_shader_parameter("start_time", Time.get_ticks_msec() / 1000)
	process_material.set_shader_parameter("expansion_speed_factor", EXPANSION_SPEED_FACTOR)
	
	#Create GPU particle process node
	var particles_3d_gpu = GPUParticles3D.new()
	particles_3d_gpu.name = "Universe"
	particles_3d_gpu.draw_pass_1 = mesh
	particles_3d_gpu.process_material = process_material
	particles_3d_gpu.lifetime = lifetime
	particles_3d_gpu.one_shot = true
	particles_3d_gpu.explosiveness = 1.0
	particles_3d_gpu.fixed_fps = 90.0
	particles_3d_gpu.amount = star_count
	particles_3d_gpu.visibility_aabb = AABB(Vector3(-SIZE/2,-SIZE/2,-SIZE/2), Vector3(SIZE,SIZE,SIZE))
	
	create_black_holes(particles_3d_gpu)
	
	return particles_3d_gpu

func delete_universe(universe):
	universe.queue_free()

func create_black_holes(universe):
	for black_hole_idx in range(0, BLACK_HOLE_COUNT):
		var b_hole = black_hole.instantiate()
		universe.add_child(b_hole)


