extends Area

signal checkpoint_reached

var is_active = false
var is_completed = false
var completed_material = load("res://assets/materials/CheckpointMarkerCompleted.material")
var active_material = load("res://assets/materials/CheckpointMarkerActive.material")

func _ready():
	if get_parent():
		# warning-ignore:return_value_discarded
		connect("checkpoint_reached", get_parent(), "checkpoint_reached")

func _on_CheckpointMarker_body_entered(_body):
	if !is_completed and is_active:
		is_completed = true
		$MeshInstance.set_surface_material(0, completed_material)
		emit_signal("checkpoint_reached")

func activate():
	is_active = true
	$MeshInstance.set_surface_material(0, active_material)
	