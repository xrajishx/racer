extends Control

func _ready():
	game_manager.reset()

func _on_Button_pressed(level):
	game_manager.current_level = level
	helper.load_scene("res://scenes/LevelLoader.tscn")
