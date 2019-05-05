extends Node

var checkpoint_marker_resource = load("res://CheckpointMarker.tscn")

var checkpoints_count = 3
var checkpoints_remaining
var checkpoint_positions

func _ready():
	checkpoints_remaining = checkpoints_count
	_spawn_car()
	checkpoint_positions = global.generate_checkpoint_positions(checkpoints_count)
	_spawn_checkpoint_markers()
	update_hud_text()

func _spawn_car():
	var spawn_distance_from_origin = (global.current_map_length / 2) * global.current_quad_size
	var height = global.get_height_at_position(spawn_distance_from_origin, spawn_distance_from_origin)
	$RaceCar.global_transform.origin = Vector3(spawn_distance_from_origin, height + 1, spawn_distance_from_origin)

func _spawn_checkpoint_markers():
	for i in checkpoint_positions.size():
		var checkpoint_marker = checkpoint_marker_resource.instance()
		add_child(checkpoint_marker)
		checkpoint_marker.global_transform.origin = checkpoint_positions[i]

func checkpoint_reached():
	checkpoints_remaining -= 1
	if checkpoints_remaining <= 0:
		$GameOver.visible = true
	update_hud_text()

func update_hud_text():
	$HUD/Checkpoints.text = "Checkpoints : " + str(checkpoints_count - checkpoints_remaining) + "/" + str(checkpoints_count)

func _on_PlayAgain_pressed():
	global.load_scene("res://Menu.tscn")
