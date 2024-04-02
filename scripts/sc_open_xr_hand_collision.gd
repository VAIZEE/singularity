@tool
extends OpenXRHand

var bone_names = ["Palm",
"Wrist",
"Thumb_Metacarpal",
"Thumb_Proximal",
"Thumb_Distal",
"Thumb_Tip",
"Index_Metacarpal",
"Index_Proximal",
"Index_Intermediate",
"Index_Distal",
"Index_Tip",
"Middle_Metacarpal",
"Middle_Proximal",
"Middle_Intermediate",
"Middle_Distal",
"Middle_Tip",
"Ring_Metacarpal",
"Ring_Proximal",
"Ring_Intermediate",
"Ring_Distal",
"Ring_Tip",
"Little_Metacarpal",
"Little_Proximal",
"Little_Intermediate",
"Little_Distal",
"Little_Tip"]

@export_flags("Palm",
"Wrist", 
"Thumb_Metacarpal",
"Thumb_Proximal",
"Thumb_Distal",
"Thumb_Tip",
"Index_Metacarpal",
"Index_Proximal",
"Index_Intermediate",
"Index_Distal",
"Index_Tip",
"Middle_Metacarpal",
"Middle_Proximal",
"Middle_Intermediate",
"Middle_Distal",
"Middle_Tip",
"Ring_Metacarpal",
"Ring_Proximal",
"Ring_Intermediate",
"Ring_Distal",
"Ring_Tip",
"Little_Metacarpal",
"Little_Proximal",
"Little_Intermediate",
"Little_Distal",
"Little_Tip") var add_collider_to = 0

@export var visualize_colliders : bool = false

var skeleton : Skeleton3D

var collider_scale : float

# Called when the node enters the scene tree for the first time.
func _ready():
	skeleton = get_node(self.hand_skeleton)
	collider_scale = skeleton.get_node("mesh_Hand_L").get_aabb().size.y / 5

	add_collider_for_selected_bones()

func is_bone_selected(n : int,value: int  )->int:
	return value & (1 << n) !=0 	

func to_correct_hand_name_string(string):
	return string + "_R" if self.hand == HAND_RIGHT else string + "_L"

func add_object_to_bone(object, bone_name):
	#Update given name to Hand specific
	bone_name = to_correct_hand_name_string(bone_name)
	
	#Add Bone Attachment to bone with given namee
	var bone_attachement = BoneAttachment3D.new()
	bone_attachement.name = bone_name
	bone_attachement.bone_idx = skeleton.find_bone(bone_name)
	bone_attachement.add_child(object)
	skeleton.add_child(bone_attachement)

func add_collider_for_bone(bone_name):
	var collider = Area3D.new()
	#################visualizer#####################
	if(visualize_colliders):
		var mesh = MeshInstance3D.new()
		mesh.mesh = SphereMesh.new()
		mesh.mesh.material = load("res://assets/material_assets/mat_player_hands.tres")
		collider.add_child(mesh)
	#################################################
	
	#Add Collider to Bone Attachment
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = SphereShape3D.new()
	collider.add_child(collision_shape)
	collider.add_to_group("finger_colliders")
	
	collider.scale *= collider_scale
	add_object_to_bone(collider, bone_name)

func add_collider_for_selected_bones():
	for bone_index in bone_names.size():
		if(is_bone_selected(bone_index, add_collider_to)):
			add_collider_for_bone(bone_names[bone_index])
