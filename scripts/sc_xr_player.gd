extends Node3D

var hand_menu = preload("res://scenes/scn_hand_menu.tscn")

#Variable to enable XR in code
var xr_interface : XRInterface

## XR active flag
var xr_active : bool = false

signal xr_ended
signal xr_started

@onready var camera : Camera3D = $XROrigin3D/XRCamera3D

@onready var left_hand : OpenXRHand = $XROrigin3D/OpenXRHandLeft
@onready var right_hand : OpenXRHand = $XROrigin3D/OpenXRHandRight

@onready var left_controller : XRController3D = $XROrigin3D/XRControllerLeft
@onready var right_controller : XRController3D = $XROrigin3D/XRControllerRight

func enableVr(): 
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("VR Enabled")
		get_viewport().use_xr = true
		#RotationMode RESET_FULL_ROTATION = 0, RotationMode RESET_BUT_KEEP_TILT = 1, RotationMode DONT_RESET_ROTATION = 2
		XRServer.center_on_hmd(1, true)
		
		xr_interface.connect("session_visible", _on_openxr_visible_state)
		xr_interface.connect("session_focussed", _on_openxr_focused_state)

# Called when the node enters the scene tree for the first time.
func _ready():
	#Do necessary stuff for vr to work
	enableVr()
	
	#add wrist menu to bone
	#left_hand.add_object_to_bone(hand_menu.instantiate(), "Wrist")
	left_hand.add_object_to_bone(hand_menu.instantiate(), "Palm")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#hand_menu.position = get_node("XROrigin3D").get_node("OpenXRHandLeft").position
	pass


# Handle OpenXR visible state
func _on_openxr_visible_state() -> void:
	# Report the XR ending
	if xr_active:
		print("OpenXR: XR ended")
		xr_active = false
		emit_signal("xr_ended")

# Handle OpenXR focused state
func _on_openxr_focused_state() -> void:
	#Report the XR starting
	if not xr_active:
		print("OpenXR: XR started")
		xr_active = true
		emit_signal("xr_started")
		#XRServer.center_on_hmd(1, true)
