extends Control

@onready var main: Control = $Main
@onready var level_select: Control = $LevelSelect
@onready var high_score: Label = %HighScore


func _ready() -> void:
	MusicPlayer.play_music(MusicPlayer.Music.MAIN_MENU)

	if GameState.save.high_score > 0:
		high_score.text += Util.get_points_text(GameState.save.high_score)
		high_score.show()


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
