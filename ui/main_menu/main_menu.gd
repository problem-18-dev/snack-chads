extends Control


func _input(_event: InputEvent) -> void:
	if _event.is_action_type():
		GameManager.main.load_scene(Main.Scene.LEVEL_ONE)
