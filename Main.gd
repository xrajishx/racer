extends Node

export var car_spawn_height = 10.0

func _ready():
	var spawn_distance_from_origin = ($GroundGenerator.map_length / 2) * $GroundGenerator.quad_size
	$Car.global_transform.origin = Vector3(spawn_distance_from_origin, car_spawn_height, spawn_distance_from_origin)