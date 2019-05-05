extends Node

var noise_octaves = 2
var noise_period = 20.0
var noise_persistence = 0.8

var default_car_audio_volume = -30
var default_car_audio_pitch_scale = 0.2

var rng
var loader

var current_scene
var current_noise_image

var current_map_length
var current_quad_size
var current_height_influence

func _ready():
	rng = RandomNumberGenerator.new()
	set_seed(randi())

func set_seed(_seed):
	rng.seed = _seed

func generate_noise_image(size):
	var noise = OpenSimplexNoise.new()

	noise.seed = rng.randi()
	noise.octaves = noise_octaves
	noise.period = noise_period
	noise.persistence = noise_persistence

	var noise_image = noise.get_image(size + 1, size + 1)
	noise_image.lock()
	
	current_noise_image = noise_image
	
	return current_noise_image

func generate_checkpoint_positions(number_of_checkpoints):
	var checkpoint_positions = []
	var padding = 20
	for _i in range(0, number_of_checkpoints):
		var randomX = (rng.randi() % ((current_map_length) - (padding * 2))) + padding
		var randomZ = (rng.randi() % ((current_map_length) - (padding * 2))) + padding
		var randomY = current_noise_image.get_pixel(randomX, randomZ).r * current_height_influence

		var checkpoint_position = Vector3(randomX * current_quad_size, randomY, randomZ * current_quad_size)
		checkpoint_positions.push_back(checkpoint_position)
	
	return checkpoint_positions

func get_height_at_position(x, y):
	return current_noise_image.get_pixel(x / current_quad_size, y / current_quad_size).r * current_height_influence

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