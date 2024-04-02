extends Node3D
#https://en.wikipedia.org/wiki/Naked_singularity#:~:text=Hence%2C%20objects%20inside%20the%20event,be%20observable%20from%20the%20outside.
var rng = RandomNumberGenerator.new()

@export var STAR_COUNT : int = 300000 #max for 90 fps was 5.000.000 rendered still
@export var LIFE_TIME : int = 100
@export var TIME_TILL_BIG_BANG : int = 5

@export var BLACK_HOLE_COUNT : int = 2

@onready var animation_idle_singularity : AnimationPlayer = $AnimationPlayer
@onready var light_effect : OmniLight3D = $Light
@onready var star_light : Node3D = $StarLight

@onready var singularity_center : MeshInstance3D = $center

var particle_universe_shader = preload("res://shaders/sh_process_particle_universe.gdshader")
var black_hole = preload("res://scenes/scn_black_hole.tscn")
 
var universe : GPUParticles3D = null
var simulation_ended : bool = true
var simulation_paused : bool = false


signal finished
signal started

# Called when the node enters the scene tree for the first time.
func _ready():
	#Startup Pulsating Effect
	animation_idle_singularity.play("singularity_wobble")
	
	#Connect press to start trigger
	singularity_center.pressed.connect(start)
	
	create_black_holes()
	
	#await get_tree().create_timer(TIME_TILL_BIG_BANG).timeout
	#universe = create_universe(LIFE_TIME, STAR_COUNT)
	#self.add_child(universe)

func start():
	if(universe == null):
		
		universe = create_universe(LIFE_TIME, STAR_COUNT)
		self.add_child(universe)
		
		started.emit()
		simulation_ended = false
		get_tree().create_timer(LIFE_TIME * 2.2).timeout.connect(set_finished)
		singularity_center.visible = false
		animation_idle_singularity.stop()
		star_light.visible = true
	
	elif (simulation_ended):
		universe.process_material.set_shader_parameter("start_time", Time.get_ticks_msec() / 1000)
		universe.restart()
		
		started.emit()
		simulation_ended = false
		get_tree().create_timer(LIFE_TIME * 2.2).timeout.connect(set_finished)
		singularity_center.visible = false
		animation_idle_singularity.stop()
		star_light.visible = true


func set_finished():
	simulation_ended = true
	singularity_center.visible = true
	animation_idle_singularity.play("singularity_wobble")
	star_light.visible = false
	finished.emit()

func restart():
	if (simulation_ended):
		simulation_ended = false
		#await get_tree().create_timer(TIME_TILL_BIG_BANG).timeout
		universe.restart()
		get_tree().create_timer(LIFE_TIME * 2.2).timeout.connect(set_finished)


func pause():
	simulation_paused = !simulation_paused
	universe.speed_scale = 0.0 if simulation_paused else 1.0


func create_universe(lifetime, star_count):
	#TODO eigenen shader
	var emissive_material = load("res://assets/material_assets/mat_particle.tres")
	#emissive_material.use_particle_trails = true
	
	#Create Particle Mesh
	var mesh = PointMesh.new()
	mesh.material = emissive_material
	
	#Create GPU particle process Material
	var process_material = ShaderMaterial.new()
	process_material.set_shader(particle_universe_shader)
	process_material.set_shader_parameter("origin", Vector3(self.global_position))
	print(Time.get_ticks_msec())
	process_material.set_shader_parameter("start_time", Time.get_ticks_msec() / 1000)
	
	#Create GPU particle process node
	var particles_3d_gpu = GPUParticles3D.new()
	particles_3d_gpu.draw_pass_1 = mesh
	particles_3d_gpu.process_material = process_material
	particles_3d_gpu.lifetime = lifetime
	particles_3d_gpu.one_shot = true
	particles_3d_gpu.explosiveness = 1.0
	particles_3d_gpu.fixed_fps = 90.0
	particles_3d_gpu.amount = star_count
	particles_3d_gpu.trail_enabled = true
	
	return particles_3d_gpu

func create_black_holes():
	var b_hole = black_hole.instantiate()
	b_hole.global_position = Vector3(0.0, -1, -1)
	b_hole.radius = 0.4
	b_hole.strength = 0.8
	b_hole.attenuation = 0.1
	self.add_child(b_hole)
	
	#var b_hole2 = black_hole.instantiate()
	#b_hole2.global_position = Vector3(-0.5, -1, -1)
	#b_hole2.radius = 0.4
	#b_hole2.strength = 0.1
	#b_hole2.attenuation = 0.35
	#self.add_child(b_hole2)
	
	
	
	for black_hole_idx in range(0, BLACK_HOLE_COUNT):
		pass



func _process(delta):
	if(!simulation_ended):
		var b_holes = get_tree().get_nodes_in_group("black_holes")
		#for b_hole in b_holes:
			#b_hole.global_position += Vector3(0.01,0,0) * delta
	pass

func _exit_tree():
	pass
