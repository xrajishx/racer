extends Spatial

var material = load("res://assets/outline.material")

func _enter_tree():
	var outline_mesh = $tree.mesh.create_outline(0.05)
	var outline_mesh_instance = MeshInstance.new()
	outline_mesh_instance.set_mesh(outline_mesh)
	outline_mesh_instance.set_surface_material(0, material)
	outline_mesh_instance.create_trimesh_collision()
	add_child(outline_mesh_instance)