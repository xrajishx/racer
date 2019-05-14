extends Node

var levels = [
	{
		'seed': 1,
		'ground': 'desert',
		'checkpoints_count': 5,
		'map_length': 100,
		'quad_size': 4.0,
		'height_influence': 10,
		'tree_counts': [
			0,
			0,
			300,
			0,
			0
		],
		'noise': {
			'octaves': 2,
			'period': 20.0,
			'persistence': 0.8
		},
		'times': [
			35.0,
			40.0,
			45.0
		]
	},
	{
		'seed': 2,
		'ground': 'snow',
		'checkpoints_count': 8,
		'map_length': 120,
		'quad_size': 4.0,
		'height_influence': 20,
		'tree_counts': [
			0,
			0,
			0,
			0,
			600
		],
		'noise': {
			'octaves': 2,
			'period': 20.0,
			'persistence': 0.8
		},
		'times': [
			60.0,
			65.0,
			70.0
		]
	},
	{
		'seed': 3,
		'ground': 'green',
		'checkpoints_count': 10,
		'map_length': 150,
		'quad_size': 4.0,
		'height_influence': 40,
		'tree_counts': [
			400,
			400,
			0,
			400,
			0
		],
		'noise': {
			'octaves': 2,
			'period': 20.0,
			'persistence': 0.8
		},
		'times': [
			140.0,
			160.0,
			180.0
		]
	}
]