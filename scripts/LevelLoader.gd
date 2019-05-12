extends Node

var thread = Thread.new()

export var smooth_shading = false

var ground_material = load("res://assets/green_ground.material")
var outline_material = load("res://assets/outline.material")

var percent_complete = 0.0

var vertices = PoolVector3Array()
var vertices_dictionary = {}

var indeces = []

var current_level_info = level_info.levels[0]

func _ready():
	game_manager.reset()
	game_manager.current_level_info = current_level_info
	game_manager.current_rng = RandomNumberGenerator.new()
	game_manager.current_rng.set_seed(current_level_info.seed)

	$LoadingScreen/Label2.text = '0'
	if(thread.is_active()):
		return

	thread.start(self, "_generate_level")

func _generate_level(_data):
	helper.generate_noise_image(current_level_info.map_length)
	
	var ground_mesh = _generate_ground_mesh()
	_create_ground_mesh_instances(ground_mesh)
	_generate_checkpoint_positions(current_level_info.checkpoints_count)
	_generate_tree_positions(current_level_info.tree_counts)

	call_deferred("_generate_level_completed")

func _generate_level_completed():
	thread.wait_to_finish()
	helper.load_scene("res://scenes/Main.tscn")

func _update_percent_completed(value):
	if(floor(value) > percent_complete):
		percent_complete = floor(value)
		$LoadingScreen/Label2.text = str(percent_complete)

func _generate_ground_mesh():
	var result_mesh = Mesh.new();
	var surface_tool = SurfaceTool.new();
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);
	_generate_mesh_data()
	surface_tool.add_smooth_group(smooth_shading)

	for vertex in vertices:
		surface_tool.add_vertex(vertex)
	for index in indeces:
		surface_tool.add_index(index)
	_update_percent_completed(percent_complete + 10)

	surface_tool.generate_normals()
	_update_percent_completed(percent_complete + 20)

	result_mesh = surface_tool.commit()
	_update_percent_completed(percent_complete + 10)
	return result_mesh

func _create_ground_mesh_instances(mesh_data):
	var mesh_instance = MeshInstance.new()
	var outline_mesh_instance = MeshInstance.new()
	mesh_instance.set_mesh(mesh_data)
	mesh_instance.create_trimesh_collision()
	mesh_instance.set_surface_material(0, ground_material)
	
	outline_mesh_instance.set_mesh(mesh_data.create_outline(0.1))
	outline_mesh_instance.set_surface_material(0, outline_material)
	
	game_manager.current_level_mesh_resource = mesh_instance
	game_manager.current_level_outline_mesh_resource = outline_mesh_instance

func _generate_mesh_data():
	var noise_image = game_manager.current_level_noise_image
	for i in range(0, current_level_info.map_length):
		for j in range(0, current_level_info.map_length):
			var point_one = Vector3(
				i * current_level_info.quad_size,
				current_level_info.height_influence * noise_image.get_pixel(i, j).r,
				j * current_level_info.quad_size
			)
			var point_two = Vector3(
				i * current_level_info.quad_size,
				current_level_info.height_influence * noise_image.get_pixel(i, j + 1).r,
				j * current_level_info.quad_size + current_level_info.quad_size
			)
			var point_three = Vector3(
				i * current_level_info.quad_size + current_level_info.quad_size,
				current_level_info.height_influence * noise_image.get_pixel(i + 1, j + 1).r,
				j * current_level_info.quad_size + current_level_info.quad_size
			)
			var point_four = Vector3(
				i * current_level_info.quad_size + current_level_info.quad_size,
				current_level_info.height_influence * noise_image.get_pixel(i + 1, j).r,
				j * current_level_info.quad_size
			)
			
			var point_one_index = _add_or_get_vertex_index(point_one)
			var point_two_index = _add_or_get_vertex_index(point_two)
			var point_three_index = _add_or_get_vertex_index(point_three)
			var point_four_index = _add_or_get_vertex_index(point_four)

			indeces.push_back(point_one_index)
			indeces.push_back(point_four_index)
			indeces.push_back(point_three_index)
			indeces.push_back(point_three_index)
			indeces.push_back(point_two_index)
			indeces.push_back(point_one_index)

		_update_percent_completed((i + 1) / float(current_level_info.map_length) * 60)

func _add_or_get_vertex_index(vertex):
	if vertices_dictionary.has(vertex):
		return vertices_dictionary[vertex]
	else:
		vertices.push_back(vertex)
		vertices_dictionary[vertex] = vertices.size() - 1
		return vertices.size() - 1

func _generate_checkpoint_positions(number_of_checkpoints):
	var checkpoint_positions = []
	var padding = 20
	for _i in range(0, number_of_checkpoints):
		var randomX = (game_manager.current_rng.randi() % ((current_level_info.map_length) - (padding * 2))) + padding
		var randomZ = (game_manager.current_rng.randi() % ((current_level_info.map_length) - (padding * 2))) + padding
		var randomY = game_manager.current_level_noise_image.get_pixel(randomX, randomZ).r * current_level_info.height_influence

		var checkpoint_position = Vector3(randomX * current_level_info.quad_size, randomY, randomZ * current_level_info.quad_size)
		checkpoint_positions.push_back(checkpoint_position)

	game_manager.current_level_checkpoint_positions = checkpoint_positions

func _generate_tree_positions(tree_counts):
	for tree_count in tree_counts:
		var tree_positions = []
		var padding = 20
		for _i in range(0, tree_count):
			var randomX = (game_manager.current_rng.randi() % ((current_level_info.map_length) - (padding * 2))) + padding
			var randomZ = (game_manager.current_rng.randi() % ((current_level_info.map_length) - (padding * 2))) + padding
			var randomY = game_manager.current_level_noise_image.get_pixel(randomX, randomZ).r * current_level_info.height_influence
	
			var tree_position = Vector3(randomX * current_level_info.quad_size, randomY, randomZ * current_level_info.quad_size)
			tree_positions.push_back(tree_position)

		game_manager.current_level_tree_positions.push_back(tree_positions)