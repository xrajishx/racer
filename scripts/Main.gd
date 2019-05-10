extends Node

var checkpoint_marker_resource = load("res://scenes/CheckpointMarker.tscn")

var first_tree_resource = load("res://assets/trees/Tree1.tscn")
var second_tree_resource = load("res://assets/trees/Tree2.tscn")
var third_tree_resource = load("res://assets/trees/Tree3.tscn")
var fourth_tree_resource = load("res://assets/trees/Tree4.tscn")
#var fifth_tree_resource = load("res://assets/trees/Tree5.tscn")

var respawn_position

var checkpoints_count = 10
var checkpoints_completed = 0
var checkpoints = []
var checkpoint_positions

var first_trees_count = 50
var first_tree_positions

var second_trees_count = 50
var second_tree_positions

var third_trees_count = 50
var third_tree_positions

var fourth_trees_count = 50
var fourth_tree_positions

var next_checkpoint_position

var viewport_size
var waypoint_marker_size
var waypoint_marker_pos_min
var waypoint_marker_pos_max

func _ready():
	_spawn_car()
	checkpoint_positions = global.generate_checkpoint_positions(checkpoints_count)

	# Generate tree positions
	first_tree_positions = global.generate_tree_positions(first_trees_count)
	second_tree_positions = global.generate_tree_positions(second_trees_count)
	third_tree_positions = global.generate_tree_positions(third_trees_count)
	fourth_tree_positions = global.generate_tree_positions(fourth_trees_count)

	next_checkpoint_position = checkpoint_positions[0]
	_spawn_checkpoint_markers()

	_spawn_trees(first_tree_positions, first_tree_resource)
	_spawn_trees(second_tree_positions, second_tree_resource)
	_spawn_trees(third_tree_positions, third_tree_resource)
	_spawn_trees(fourth_tree_positions, fourth_tree_resource)

	update_hud_text()
	waypoint_marker_size = $HUD/Waypoint.get_rect().size
	viewport_size = get_viewport().size

	waypoint_marker_pos_min = Vector2(0 + waypoint_marker_size.x, 0 + waypoint_marker_size.y)
	waypoint_marker_pos_max = Vector2(viewport_size.x - waypoint_marker_size.x, viewport_size.y - viewport_size.y / 2)

func _spawn_car():
	var spawn_distance_from_origin = (global.current_map_length / 2) * global.current_quad_size
	var height = global.get_height_at_position(spawn_distance_from_origin, spawn_distance_from_origin)
	respawn_position = Vector3(spawn_distance_from_origin, height + 1, spawn_distance_from_origin)
	$RaceCar.global_transform.origin = respawn_position

func _spawn_checkpoint_markers():
	print(checkpoint_marker_resource)
	for i in checkpoint_positions.size():
		var checkpoint_marker = checkpoint_marker_resource.instance()
		checkpoints.push_back(checkpoint_marker)
		add_child(checkpoint_marker)
		checkpoint_marker.global_transform.origin = checkpoint_positions[i]
	checkpoints[0].activate()

func _spawn_trees(positions, resource):
	for i in positions.size():
		var tree = resource.instance()
		add_child(tree)
		tree.global_transform.origin = positions[i]

func checkpoint_reached():
	respawn_position = checkpoint_positions[checkpoints_completed]
	checkpoints_completed += 1
	if checkpoints_completed >= checkpoints_count:
		$GameOver.visible = true
		$HUD/Waypoint.visible = false
	else:
		next_checkpoint_position = checkpoint_positions[checkpoints_completed]
		_activate_next_checkpoint()
	update_hud_text()

func _activate_next_checkpoint():
	checkpoints[checkpoints_completed].activate()

func update_hud_text():
	$HUD/Checkpoints.text = "Checkpoints : " + str(checkpoints_completed) + "/" + str(checkpoints_count)

func _on_PlayAgain_pressed():
	global.load_scene("res://scenes/Loading.tscn")

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
			waypoint_marker_position.x = waypoint_marker_pos_max.x
		else:
			waypoint_marker_position.x = waypoint_marker_pos_min.x

	$HUD/Waypoint.position = waypoint_marker_position
	$HUD/Waypoint/Label.text = str((floor($RaceCar.translation.distance_to(next_checkpoint_position)) - 5) / 10)
	$HUD/Speed.text = str((floor($RaceCar.linear_velocity.length())))

func _on_RaceCar_respawn():
	$RaceCar.linear_velocity = Vector3.ZERO
	$RaceCar.global_transform.origin = respawn_position