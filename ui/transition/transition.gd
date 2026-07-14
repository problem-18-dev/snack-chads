extends Control


func transition_to_level() -> void:
	var next_level: Main.Scene = GameManager.get_next_level()
	GameManager.main.load_scene(next_level)
