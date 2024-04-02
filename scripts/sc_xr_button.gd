extends MeshInstance3D

@onready var interaction_area : Area3D = $Area3D

signal pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	interaction_area.connect("area_entered", on_interaction_area_entered)


func on_interaction_area_entered(area):
	pressed.emit()

func set_active(active):
	interaction_area.monitoring = active
