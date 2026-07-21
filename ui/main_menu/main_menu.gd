extends Control

@onready var main: Control = $Main
@onready var level_select: Control = $"Level Select"


func _on_play_button_pressed() -> void:
	GameManager.main.load_scene(Main.Scene.LEVEL_ONE)


func _on_levels_button_pressed() -> void:
	main.hide()
	level_select.show()


func _on_back_button_pressed() -> void:
	level_select.hide()
	main.show()


func _on_level_one_button_pressed() -> void:
	GameManager.main.load_scene(Main.Scene.LEVEL_ONE)


func _on_level_two_button_pressed() -> void:
	GameManager.main.load_scene(Main.Scene.LEVEL_TWO)


func _on_level_three_button_pressed() -> void:
	GameManager.main.load_scene(Main.Scene.LEVEL_THREE)


func _on_level_four_button_pressed() -> void:
	GameManager.main.load_scene(Main.Scene.LEVEL_FOUR)
