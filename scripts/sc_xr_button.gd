extends MeshInstance3D

@onready var interaction_area : Area3D = $Area3D

const COLLISION_MASK := 0b0000_0000_0000_0000_0000_0000_0000_0001
const COLLISION_LAYER := 0b0000_0000_0000_0000_0000_0000_0000_0000

signal pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area3D.collision_layer = COLLISION_LAYER
	$Area3D.collision_mask = COLLISION_MASK
	
	interaction_area.connect("area_entered", on_interaction_area_entered)


func on_interaction_area_entered(area):
	pressed.emit()

func set_active(active):
	interaction_area.monitoring = active
