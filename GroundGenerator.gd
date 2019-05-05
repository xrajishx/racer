extends Spatial

var rng
var checkpoint_marker_resource = load("res://CheckpointMarker.tscn")

export var height_influence = 10
export var map_length = 200
export var quad_size = 4.0
export var smooth_shading = false

export var noise_octaves = 2
export var noise_period = 20.0
export var noise_persistence = 0.8

var noise_image

var vertices = PoolVector3Array()
var indeces = []

func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = global._seed

	noise_image = get_noise_image()

	var result_mesh = Mesh.new();
	var surface_tool = SurfaceTool.new();

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);
	generate_mesh_data()
	surface_tool.add_smooth_group(smooth_shading)

	for vertex in vertices:
		surface_tool.add_vertex(vertex)
	for index in indeces:
		surface_tool.add_index(index)
	
	surface_tool.generate_normals()

	result_mesh = surface_tool.commit()
	$Ground.mesh = result_mesh

	$Ground.create_trimesh_collision()
	
	var checkpoint_positions = get_checkpoint_positions(10)
	spawn_checkpoint_markers(checkpoint_positions)

func get_noise_image():
	var noise = OpenSimplexNoise.new()

	noise.seed = rng.randi()
	noise.octaves = noise_octaves
	noise.period = noise_period
	noise.persistence = noise_persistence

	var noise_image = noise.get_image(map_length + 1, map_length + 1)
	noise_image.lock()
	
	return noise_image

func get_checkpoint_positions(number_of_checkpoints):
	var checkpoint_positions = []
	var padding = 20
	for i in range(0, number_of_checkpoints):
		var randomX = (rng.randi() % ((map_length) - (padding * 2))) + padding
		var randomZ = (rng.randi() % ((map_length) - (padding * 2))) + padding
		var randomY = noise_image.get_pixel(randomX, randomZ).r * height_influence
		
		var checkpoint_position = Vector3(randomX * quad_size, randomY, randomZ * quad_size)
		checkpoint_positions.push_back(checkpoint_position)
	
	return checkpoint_positions

func spawn_checkpoint_markers(checkpoint_positions):
	for i in checkpoint_positions.size():
		var checkpoint_marker = checkpoint_marker_resource.instance()
		add_child(checkpoint_marker)
		checkpoint_marker.global_transform.origin = checkpoint_positions[i]

func generate_mesh_data():
	for i in range(0, map_length):
		for j in range(0, map_length):
			var point_one = Vector3(
				i * quad_size,
				height_influence * noise_image.get_pixel(i, j).r,
				j * quad_size
			)
			var point_two = Vector3(
				i * quad_size,
				height_influence * noise_image.get_pixel(i, j + 1).r,
				j * quad_size + quad_size
			)
			var point_three = Vector3(
				i * quad_size + quad_size,
				height_influence * noise_image.get_pixel(i + 1, j + 1).r,
				j * quad_size + quad_size
			)
			var point_four = Vector3(
				i * quad_size + quad_size,
				height_influence * noise_image.get_pixel(i + 1, j).r,
				j * quad_size
			)

			var current_number_of_vertices = vertices.size()
			vertices.push_back(point_one)
			vertices.push_back(point_two)
			vertices.push_back(point_three)
			vertices.push_back(point_four)

			indeces.push_back(current_number_of_vertices)
			indeces.push_back(current_number_of_vertices + 3)
			indeces.push_back(current_number_of_vertices + 2)
			indeces.push_back(current_number_of_vertices + 2)
			indeces.push_back(current_number_of_vertices + 1)
			indeces.push_back(current_number_of_vertices)