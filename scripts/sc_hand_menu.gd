extends Node3D

@onready var pause_button : MeshInstance3D = $Clock/PauseButton
@onready var exit_button : MeshInstance3D = $Clock/ExitButton
@onready var restart_button : MeshInstance3D = $Clock/RestartButton

@onready var animation_disc_spin : AnimationPlayer = $AnimationPlayerDisc
@onready var animation_open_menu : AnimationPlayer = $AnimationPlayerMenu

@onready var camera : Camera3D = get_viewport().get_camera_3d()

var menu_open : bool = true

signal restart
signal pause

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_button.pressed.connect(on_pause_pressed)
	exit_button.pressed.connect(on_exit_pressed)
	restart_button.pressed.connect(on_restart_pressed)


func on_pause_pressed():
	pause.emit()

func on_exit_pressed():
	print("EXIT")
	quit_game()

func on_restart_pressed():
	restart.emit()

func toggle_menu():
	menu_open = !menu_open

	pause_button.set_active(menu_open)

	exit_button.set_active(menu_open)

	restart_button.set_active(menu_open)
	
	if(menu_open):
		animation_disc_spin.play("DiscSpin")
		animation_open_menu.play("OpenMenu")
	else:
		animation_open_menu.play_backwards("OpenMenu")
		animation_disc_spin.stop()
		
func _physics_process(delta):
	var view_dir = camera.get_global_transform().basis.z
	var angle_to_camera = rad_to_deg(view_dir.angle_to($Clock/Disc.get_global_transform().basis.y))
	if(menu_open and angle_to_camera > 90.0 or !menu_open and angle_to_camera <= 90.0):
		toggle_menu()
		
func quit_game():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
