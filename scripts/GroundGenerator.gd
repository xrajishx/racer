extends Spatial

export var map_length = 200
export var quad_size = 4.0
export var height_influence = 10
export var smooth_shading = false

var ground_material = load("res://assets/green_ground.material")
var outline_material = load("res://assets/outline.material")

var noise_image

var vertices = PoolVector3Array()
var vertices_dictionary = {}

var indeces = []

func _ready():
	global.current_map_length = map_length
	global.current_quad_size = quad_size
	global.current_height_influence = height_influence

	noise_image = global.generate_noise_image(map_length)

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
	_add_mesh_instance_child(result_mesh)

func _add_mesh_instance_child(mesh_data):
	var mesh_instance = MeshInstance.new()
	var outline_mesh_instance = MeshInstance.new()
	mesh_instance.set_mesh(mesh_data)
	mesh_instance.create_trimesh_collision()
	mesh_instance.set_surface_material(0, ground_material)
	
	outline_mesh_instance.set_mesh(mesh_data.create_outline(0.1))
	outline_mesh_instance.set_surface_material(0, outline_material)
	add_child(mesh_instance)
	add_child(outline_mesh_instance)

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

func _add_or_get_vertex_index(vertex):
	if vertices_dictionary.has(vertex):
		return vertices_dictionary[vertex]
	else:
		vertices.push_back(vertex)
		vertices_dictionary[vertex] = vertices.size() - 1
		return vertices.size() - 1