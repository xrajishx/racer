extends Spatial

export var height_influence = 10
export var map_length = 200
export var quad_size = 4.0
export var smooth_shading = false

var vertices = PoolVector3Array()
var indeces = []

func _ready():
	randomize()
	var noise = OpenSimplexNoise.new()

	noise.seed = randi()
	noise.octaves = 2
	noise.period = 20.0
	noise.persistence = 0.8

	var noise_image = noise.get_image(map_length + 1, map_length + 1)
	noise_image.lock()

	var result_mesh = Mesh.new();
	var surface_tool = SurfaceTool.new();

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);

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

	surface_tool.add_smooth_group(smooth_shading)

	for vertex in vertices:
		surface_tool.add_vertex(vertex)
	for index in indeces:
		surface_tool.add_index(index)
	
	surface_tool.generate_normals()

	result_mesh = surface_tool.commit()
	$Ground.mesh = result_mesh

	$Ground.create_trimesh_collision()