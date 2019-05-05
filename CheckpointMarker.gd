extends Area

signal checkpoint_reached

var checkpoint_reached = false
var completed_material = load("res://assets/CheckpointMarkerCompleted.material")

func _ready():
	if get_parent():
		# warning-ignore:return_value_discarded
		connect("checkpoint_reached", get_parent(), "checkpoint_reached")

func _on_CheckpointMarker_body_entered(_body):
	if !checkpoint_reached:
		checkpoint_reached = true
		$MeshInstance.set_surface_material(0, completed_material)
		emit_signal("checkpoint_reached")