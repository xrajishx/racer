extends Node

var current_rng

var current_level_info
var current_level_noise_image

var current_level_mesh_resource
var current_level_outline_mesh_resource
var current_level_checkpoint_positions = []
var current_level_tree_positions = []

func reset():
	current_rng = null

	current_level_info = null
	current_level_noise_image = null

	current_level_mesh_resource = null
	current_level_outline_mesh_resource = null
	current_level_checkpoint_positions = []
	current_level_tree_positions = []