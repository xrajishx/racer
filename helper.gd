extends Node

var default_car_audio_volume = -30
var default_car_audio_pitch_scale = 0.2

var loader

var current_scene

func generate_noise_image(size):
	var current_level_info = game_manager.current_level_info
	var noise = OpenSimplexNoise.new()

	noise.seed = game_manager.current_rng.randi()
	noise.octaves = current_level_info.noise.octaves
	noise.period = current_level_info.noise.period
	noise.persistence = current_level_info.noise.persistence

	var noise_image = noise.get_seamless_image(size + 1)
	noise_image.lock()
	
	game_manager.current_level_noise_image = noise_image

func get_height_at_position(x, y):
	var current_level_info = game_manager.current_level_info
	return game_manager.current_level_noise_image.get_pixel(
		x / current_level_info.quad_size,
		y / current_level_info.quad_size
	).r * current_level_info.height_influence

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