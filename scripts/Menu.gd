extends Control

func _ready():
	game_manager.reset()

func _on_level_selected(level):
	game_manager.current_level = level
	helper.load_scene("res://scenes/LevelLoader.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()