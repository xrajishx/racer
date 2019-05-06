extends Node

var checkpoint_marker_resource = load("res://CheckpointMarker.tscn")

var checkpoints_count = 3
var checkpoints_remaining
var checkpoint_positions

var next_checkpoint_position

var viewport_size
var waypoint_marker_size
var waypoint_marker_pos_min
var waypoint_marker_pos_max

func _ready():
	checkpoints_remaining = checkpoints_count
	_spawn_car()
	checkpoint_positions = global.generate_checkpoint_positions(checkpoints_count)
	next_checkpoint_position = checkpoint_positions[0]
	_spawn_checkpoint_markers()
	update_hud_text()
	waypoint_marker_size = $HUD/Waypoint.get_rect().size
	viewport_size = get_viewport().size

	waypoint_marker_pos_min = Vector2(0 + waypoint_marker_size.x, 0 + waypoint_marker_size.y)
	waypoint_marker_pos_max = Vector2(viewport_size.x - waypoint_marker_size.x, viewport_size.y - viewport_size.y / 2)

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
		$HUD/Waypoint.visible = false
	else:
		next_checkpoint_position = checkpoint_positions[checkpoints_count - checkpoints_remaining]
	update_hud_text()

func update_hud_text():
	$HUD/Checkpoints.text = "Checkpoints : " + str(checkpoints_count - checkpoints_remaining) + "/" + str(checkpoints_count)

func _on_PlayAgain_pressed():
	global.load_scene("res://Menu.tscn")

func _process(_delta):
	var waypoint_marker_position = $Camera.unproject_position(Vector3(
		next_checkpoint_position.x,
		next_checkpoint_position.y + 10,
		next_checkpoint_position.z)
	)
	waypoint_marker_position.x = clamp(waypoint_marker_position.x, waypoint_marker_pos_min.x, waypoint_marker_pos_max.x)
	waypoint_marker_position.y = clamp(waypoint_marker_position.y, waypoint_marker_pos_min.y, waypoint_marker_pos_max.y)
	
	if($Camera.get_transform().basis.z.dot(next_checkpoint_position - $Camera.translation) > 0):
		if waypoint_marker_position.x < viewport_size.x / 2:
			waypoint_marker_position.x = waypoint_marker_pos_min.x
		else:
			waypoint_marker_position.x = waypoint_marker_pos_max.x

	$HUD/Waypoint.position = waypoint_marker_position
	$HUD/Waypoint/Label.text = str((floor($RaceCar.translation.distance_to(next_checkpoint_position)) - 5) / 10)