extends Control


func _input(_event: InputEvent) -> void:
	if _event.is_action_type():
		GameState.reset()
		GameManager.main.load_scene(Main.Scene.MAIN_MENU)
