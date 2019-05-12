extends Node

var current_level_info

var current_level_noise_image

var current_level_mesh_resource
var current_level_outline_mesh_resource
var current_level_checkpoint_positions = []
var current_level_tree_positions = []

func init():
	current_level_noise_image = null
	
	current_level_mesh_resource = null
	current_level_outline_mesh_resource = null
	current_level_checkpoint_positions = []
	current_level_tree_positions = []