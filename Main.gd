extends Node

export var car_spawn_height = 10.0

var checkpoints = 10

func _ready():
	var spawn_distance_from_origin = ($GroundGenerator.map_length / 2) * $GroundGenerator.quad_size
	$RaceCar.global_transform.origin = Vector3(spawn_distance_from_origin, car_spawn_height, spawn_distance_from_origin)

func _on_RaceCar_collided_with_checkpoint_marker():
	checkpoints -= 1
	if(checkpoints == 0):
		$Control.visible = true
