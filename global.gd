extends Node

var _seed = 12345

var loader
var current_scene

func load_scene(path):
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	loader = ResourceLoader.load_interactive(path)
	set_process(true)

func _process(_delta):
	if loader == null:
		set_process(false)
		return

	var err = loader.poll()

	if err == ERR_FILE_EOF:
		var resource = loader.get_resource()
		loader = null
		set_new_scene(resource)
	elif err != OK:
		print('Something went wrong')
		loader = null


func set_new_scene(scene_resource):
	current_scene.queue_free()
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)